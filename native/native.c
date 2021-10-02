/*
    Copyright (c) 2021 Xubai Wang. All rights reserved.
    Released under Apache 2.0 license as described in the file LICENSE.
    Authors: Xubai Wang
*/

// ==============================================================================
// # Includes
// ==============================================================================

#include <lean/lean.h>
#include <stdint.h>
#include <stdio.h>

#ifdef _WIN32

#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0600
#endif
#include <winsock2.h>
#include <ws2tcpip.h>
#include <winbase.h>
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "advapi32.lib")

#else

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <errno.h>

#endif

// ==============================================================================
// # Utilities
// ==============================================================================

// ## Cross Platform Socket Definitions

#ifdef _WIN32

#define ISVALIDSOCKET(s) ((s) != INVALID_SOCKET)
#define CLOSESOCKET(s) closesocket(s)

#ifndef IPV6_V6ONLY
#define IPV6_V6ONLY 27
#endif

#else

#define ISVALIDSOCKET(s) ((s) >= 0)
#define CLOSESOCKET(s) close(s)
#define SOCKET int

#endif

// ## Conversion

static int domain_decode(uint8_t domain)
{
    switch (domain)
    {
    case 0:
        return AF_INET;
    case 1:
        return AF_INET6;
    default:
        return -1;
    }
}

static int type_decode(uint8_t type)
{
    switch (type)
    {
    case 0:
        return SOCK_STREAM;
    case 1:
        return SOCK_DGRAM;
    default:
        return -1;
    }
}

/**
 * use macro instead of function to avoid foward declaration
 */
#define SOCKET_BOX(s) lean_alloc_external(g_socket_external_class, s)

/**
 * use macro instead of function to avoid foward declaration
 */
#define SOCKET_UNBOX(s) (*(SOCKET *)(lean_get_external_data(s)))

/**
 * use macro instead of function to avoid foward declaration
 */
#define SOCKADDR_BOX(s) lean_alloc_external(g_sockaddr_external_class, s)

/**
 * use macro instead of function to avoid foward declaration
 */
#define SOCKADDR_UNBOX(s) ((struct sockaddrwithlen *)(lean_get_external_data(s)))

/**
 * Group sockaddr and its length together as a external class.
 */
static struct sockaddrwithlen
{
    socklen_t address_len;
    struct sockaddr_storage address;
};

// ## Errors

extern lean_obj_res lean_mk_io_user_error(lean_obj_arg);
extern lean_obj_res lean_mk_io_error_eof(lean_obj_arg);
extern lean_obj_res lean_mk_io_error_interrupted(lean_obj_arg, uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_unsupported_operation(uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_resource_exhausted(uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_already_exists(uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_inappropriate_type(uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_no_such_thing(uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_resource_vanished(uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_resource_busy(uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_invalid_argument(uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_other_error(uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_permission_denied(uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_hardware_fault(uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_unsatisfied_constraints(uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_illegal_operation(uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_protocol_error(uint32_t, lean_obj_arg);
extern lean_obj_res lean_mk_io_error_time_expired(uint32_t, lean_obj_arg);

lean_obj_res mk_io_error(int errnum, lean_obj_arg details)
{
    switch (errnum)
    {
#ifdef _WIN32
        // TODO(xubaiw): WSA Error handling, now all passed to default
#else
    case EINTR:
        return lean_mk_io_error_interrupted(lean_mk_string(""), errnum, details);
    case ELOOP:
    case ENAMETOOLONG:
    case EDESTADDRREQ:
    case EBADF:
    case EDOM:
    case EINVAL:
    case EILSEQ:
    case ENOEXEC:
    case ENOSTR:
    case ENOTCONN:
    case ENOTSOCK:
        return lean_mk_io_error_invalid_argument(errnum, details);
    case EACCES:
    case EROFS:
    case ECONNABORTED:
    case EFBIG:
    case EPERM:
        return lean_mk_io_error_permission_denied(errnum, details);
    case EMFILE:
    case ENFILE:
    case ENOSPC:
    case E2BIG:
    case EAGAIN:
    case EMLINK:
    case EMSGSIZE:
    case ENOBUFS:
    case ENOLCK:
    case ENOMEM:
    case ENOSR:
        return lean_mk_io_error_resource_exhausted(errnum, details);
    case EISDIR:
    case EBADMSG:
    case ENOTDIR:
        return lean_mk_io_error_inappropriate_type(errnum, details);
    case ENXIO:
    case EHOSTUNREACH:
    case ENETUNREACH:
    case ECHILD:
    case ECONNREFUSED:
    case ENODATA:
    case ENOMSG:
    case ESRCH:
        return lean_mk_io_error_no_such_thing(errnum, details);
    case EEXIST:
    case EINPROGRESS:
    case EISCONN:
        return lean_mk_io_error_already_exists(errnum, details);
    case EIO:
        return lean_mk_io_error_hardware_fault(errnum, details);
    case ENOTEMPTY:
        return lean_mk_io_error_unsatisfied_constraints(errnum, details);
    case ENOTTY:
        return lean_mk_io_error_illegal_operation(errnum, details);
    case ECONNRESET:
    case EIDRM:
    case ENETDOWN:
    case ENETRESET:
    case ENOLINK:
    case EPIPE:
        return lean_mk_io_error_resource_vanished(errnum, details);
    case EPROTO:
    case EPROTONOSUPPORT:
    case EPROTOTYPE:
        return lean_mk_io_error_protocol_error(errnum, details);
    case ETIME:
    case ETIMEDOUT:
        return lean_mk_io_error_time_expired(errnum, details);
    case EADDRINUSE:
    case EBUSY:
    case EDEADLK:
    case ETXTBSY:
        return lean_mk_io_error_resource_busy(errnum, details);
    case EADDRNOTAVAIL:
    case EAFNOSUPPORT:
    case ENODEV:
    case ENOPROTOOPT:
    case ENOSYS:
    case EOPNOTSUPP:
    case ERANGE:
    case ESPIPE:
    case EXDEV:
        return lean_mk_io_error_unsupported_operation(errnum, details);
    case EFAULT:
        return lean_mk_io_error_other_error(errnum, details);
#endif
    default:
        return lean_mk_io_error_other_error(errnum, details);
    }
}

static lean_obj_res get_socket_error()
{
    // get errnum and error details
#ifdef _WIN32
    int errnum = WSAGetLastError();
    wchar_t *s = NULL;
    FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                   NULL, errnum,
                   MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                   (LPWSTR)&s, 0, NULL);
    lean_object *details = lean_mk_string(s);
#else
    int errnum = errno;
    lean_object *details = lean_mk_string(strerror(errnum));
#endif
    return mk_io_error(errnum, details);
}

static lean_obj_res get_addrinfo_error(int errnum)
{
    lean_object *details = lean_mk_string(gai_strerror(errnum));
    return lean_mk_io_user_error(details);
}

// ==============================================================================
// # Initialization
// ==============================================================================

// ## External Classes

/**
 * External class for Socket.
 * 
 * This class register `SOCKET *` (which is `int *` on *nix) as a lean external class.
 */
static lean_external_class *g_socket_external_class = NULL;

/**
 * External class for SockAddr.
 * 
 * This class register `sockaddrwithlen *` as a lean external class.
 */
static lean_external_class *g_sockaddr_external_class = NULL;

// ## Finalizers

/**
 * `Socket` destructor, which ensures that the socket is closed when garbage collected.
 */
inline static void socket_finalizer(void *s)
{
    CLOSESOCKET(*(SOCKET *)(s));
}

/**
 * A do nothing destructor.
 */
inline static void noop_finalizer(void *s) {}

// ## Foreach iterators

/**
 * A do nothing iterator.
 */
inline static void noop_foreach(void *mod, b_lean_obj_arg fn) {}

// ## Initialization Entry

/**
 * Initialize socket environment.
 * 
 * This function does the following things:
 * 1. register (`Socket`)`g_socket_external_class` class
 * 2. WSAStartup on windows
 * 3. register WSACleanup on windows
 * 
 * This function should always be called with `initialize`.
 */
lean_obj_res lean_socket_initialize()
{
    g_socket_external_class = lean_register_external_class(socket_finalizer, noop_foreach);
    g_sockaddr_external_class = lean_register_external_class(noop_finalizer, noop_foreach);
#ifdef _WIN32
    WSADATA d;
    if (WSAStartup(MAKEWORD(2, 2), &d))
    {
        return lean_io_result_mk_error(get_socket_error());
    }
    if (atexit(WSACleanup))
    {
        int errnum = errno;
        lean_object *details = lean_mk_string(strerror(errnum));
        return lean_io_result_mk_error(mk_io_error(errnum, details));
    }
#endif
    return lean_io_result_mk_ok(lean_box(0));
}

// ==============================================================================
// # External Implementation
// ==============================================================================

// ## Socket

/**
 * constant Socket.mk (d : SockDomain) (t : SockType) : IO Socket
 */
lean_obj_res lean_socket_mk(uint8_t domain_obj, uint8_t type_obj, lean_obj_arg w)
{
    int domain = domain_decode(domain_obj);
    int type = type_decode(type_obj);
    SOCKET s = socket(domain, type, 0);
    if (ISVALIDSOCKET(s))
    {
        return lean_io_result_mk_ok(SOCKET_BOX(&s));
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

/**
 * constant Socket.close (s : @& Socket) : IO Unit
 */
lean_obj_res lean_socket_close(b_lean_obj_arg s, lean_obj_arg w)
{
    if (!CLOSESOCKET(SOCKET_UNBOX(s)))
    {
        return lean_io_result_mk_ok(lean_box(0));
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

/**
 * TODO:
 * constant Socket.connect (s : @& Socket) (a : @& SockAddr) : IO Unit
 */
lean_obj_res lean_socket_connect(b_lean_obj_arg s, b_lean_obj_arg a, lean_obj_arg w)
{
    struct sockaddrwithlen *sa = SOCKADDR_UNBOX(a);
    if (connect(SOCKET_UNBOX(s), (struct sockaddr *)&(sa->address), sa->address_len))
    {
        return lean_io_result_mk_ok(lean_box(0));
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

/**
 * TODO: 
 * constant Socket.bind (s : @& Socket) (a : @& SockAddr) : IO Unit
 */
lean_obj_res lean_socket_bind(b_lean_obj_arg s, b_lean_obj_arg a, lean_obj_arg w)
{
    struct sockaddrwithlen *sa = SOCKADDR_UNBOX(a);
    if (bind(SOCKET_UNBOX(s), (struct sockaddr *)&(sa->address), sa->address_len))
    {
        return lean_io_result_mk_ok(lean_box(0));
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

/**
 * constant Socket.listen (s : @& Socket) (n : @& UInt8) : IO Unit
 */
lean_obj_res lean_socket_listen(b_lean_obj_arg s, uint8_t n, lean_obj_arg w)
{
    if (listen(SOCKET_UNBOX(s), (int)n))
    {

        return lean_io_result_mk_ok(lean_box(0));
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

/**
 * constant Socket.accept (s : @& Socket) : IO SockAddr
 */
lean_obj_res lean_socket_accept(b_lean_obj_arg s, uint8_t n, lean_obj_arg w)
{
    // TODO:
}

/**
 * constant Socket.shutdown (s : @& Socket) (h : ShutdownHow) : IO Unit 
 */
lean_obj_res lean_socket_shutdown(b_lean_obj_arg s, uint8_t h, lean_obj_arg w)
{
    if (listen(SOCKET_UNBOX(s), h))
    {
        return lean_io_result_mk_ok(lean_box(0));
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

// ## SockAddr

/**
 * constant SockAddr.mk (host : @& String) (port : @& String) : IO SockAddr
 */
lean_obj_res lean_sockaddr_mk(b_lean_obj_arg h, b_lean_obj_arg p, lean_obj_arg w)
{
    const char *host = lean_string_cstr(h);
    const char *port = lean_string_cstr(p);
    struct addrinfo *ai_res;
    struct sockaddrwithlen res;
    int code = getaddrinfo(host, port, NULL, &ai_res);
    if (code < 0)
    {
        return lean_io_result_mk_error(get_addrinfo_error(code));
    }
    res.address_len = ai_res->ai_addrlen;
    memcpy(&(res.address), &(ai_res->ai_addr), res.address_len);
    freeaddrinfo(ai_res);
    return lean_io_result_mk_ok(SOCKADDR_BOX(&res));
}

/**
 * constant SockAddr.length (a : @&SockAddr) : UInt32
 */
uint32_t lean_sockaddr_length(b_lean_obj_arg a, lean_obj_arg w)
{
    struct sockaddrwithlen *sa = SOCKADDR_UNBOX(a);
    return sa->address_len;
}