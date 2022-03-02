// ==============================================================================
// # Includes
// ==============================================================================

#include <lean/lean.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

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
// # Statics and Types
// ==============================================================================

typedef struct sockaddr sockaddr;
typedef struct sockaddr_in sockaddr_in;
typedef struct sockaddr_in6 sockaddr_in6;
typedef struct sockaddr_storage sockaddr_storage;
typedef struct addrinfo addrinfo;

/**
 * Group sockaddr and its length together as a external class.
 */
typedef struct sockaddr_len
{
    socklen_t address_len;
    sockaddr_storage address;
} sockaddr_len;

/**
 * External class for Socket.
 * 
 * This class register `SOCKET *` (which is `int *` on *nix) as a lean external class.
 */
static lean_external_class *g_socket_external_class = NULL;

/**
 * External class for SockAddr.
 * 
 * This class register `sockaddr_len *` as a lean external class.
 */
static lean_external_class *g_sockaddr_external_class = NULL;

// ==============================================================================
// # Utilities
// ==============================================================================

// ## Socket Types and Functions

#ifdef _WIN32

#define ISVALIDSOCKET(s) ((s) != INVALID_SOCKET)
#define CLOSESOCKET(s) closesocket(s)

#ifndef IPV6_V6ONLY
#define IPV6_V6ONLY 27
#endif

static void cleanup()
{
    WSACleanup();
}

#else

#define ISVALIDSOCKET(s) ((s) >= 0)
#define CLOSESOCKET(s) close(s)
#define SOCKET int

#endif

// ## Conversion

lean_object *lean_option_mk_some(lean_object *v)
{
    lean_object *option = lean_alloc_ctor(1, 1, 0);
    lean_ctor_set(option, 0, v);
    return option;
}

lean_object *lean_option_mk_none()
{
    return lean_alloc_ctor(0, 0, 0);
}

static int address_family_unbox(uint8_t af)
{
    switch (af)
    {
    case 0:
        return AF_UNSPEC;
    case 1:
        return AF_INET;
    case 2:
        return AF_INET6;
    default:
        return AF_UNSPEC;
    }
}

static uint8_t sock_type_box(int type)
{
    switch (type)
    {
    case 0:
        return 0;
    case SOCK_STREAM:
        return 1;
    case SOCK_DGRAM:
        return 2;
    default:
        return 0;
    }
}

static int sock_type_unbox(uint8_t type)
{
    switch (type)
    {
    case 0:
        return 0;
    case 1:
        return SOCK_STREAM;
    case 2:
        return SOCK_DGRAM;
    default:
        return -1;
    }
}

/**
 * `SOCKET *` -> `lean_object *`(`Socket`) conversion
 * use macro instead of function to avoid foward declaration
 */
lean_object *socket_box(SOCKET *s)
{
    return lean_alloc_external(g_socket_external_class, s);
}

/**
 * `lean_object *`(`Socket`) -> `SOCKET *` conversion
 * use macro instead of function to avoid foward declaration
 */
SOCKET *socket_unbox(lean_object *s) { return (SOCKET *)(lean_get_external_data(s)); }

/**
 * `sockaddr_len` -> `lean_object *`(`SockAddr`) conversion
 * use macro instead of function to avoid foward declaration
 */
lean_object *sockaddr_len_box(sockaddr_len *s)
{
    return lean_alloc_external(g_sockaddr_external_class, s);
}

/**
 * `lean_object *`(`SockAddr`) -> `sockaddr_len *` conversion
 * use macro instead of function to avoid foward declaration
 */
sockaddr_len *sockaddr_len_unbox(lean_object *s)
{
    return (sockaddr_len *)(lean_get_external_data(s));
}

// ## Errors

extern lean_obj_res lean_mk_io_user_error(lean_obj_arg);

static lean_obj_res get_socket_error()
{
#ifdef _WIN32
    int errnum = WSAGetLastError();
    wchar_t *s = NULL;
    FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                   NULL, errnum,
                   MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                   (LPWSTR)&s, 0, NULL);
    char *err_str;
    wcstombs(err_str, s, 100);
    lean_object *details = lean_mk_string(err_str);
    LocalFree(s);
#else
    int errnum = errno;
    lean_object *details = lean_mk_string(strerror(errnum));
#endif
    return lean_mk_io_user_error(details);
}

// ==============================================================================
// # Initialization
// ==============================================================================

// ## Finalizers

/**
 * `Socket` destructor, which ensures that the socket is closed when garbage collected.
 */
inline static void socket_finalizer(void *socket_ptr)
{
    SOCKET *converted = (SOCKET *)socket_ptr;
    CLOSESOCKET(*converted);
    free(converted);
}

/**
 * `SockAddr` destructor, which ensures that the socket is closed when garbage collected.
 */
inline static void sockaddr_finalizer(void *sal)
{
    free((sockaddr_len *)sal);
}

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
 * 1. register `Socket` and `SockAddr` class
 * 2. WSAStartup on windows
 * 3. register WSACleanup on windows
 * 
 * This function should always be called with `initialize`.
 */
lean_obj_res lean_socket_initialize()
{
    g_socket_external_class = lean_register_external_class(socket_finalizer, noop_foreach);
    g_sockaddr_external_class = lean_register_external_class(sockaddr_finalizer, noop_foreach);
#ifdef _WIN32
    WSADATA d;
    if (WSAStartup(MAKEWORD(2, 2), &d))
    {
        return lean_io_result_mk_error(get_socket_error());
    }
    if (atexit(cleanup))
    {
        int errnum = errno;
        lean_object *details = lean_mk_string(strerror(errnum));
        return lean_io_result_mk_error(lean_mk_io_user_error(details));
    }
#endif
    return lean_io_result_mk_ok(lean_box(0));
}

// ==============================================================================
// # External Implementation
// ==============================================================================

// ## Socket

/**
 * constant Socket.mk (d : AddressFamily) (t : SockType) : IO Socket
 */
lean_obj_res lean_socket_mk(uint8_t af_obj, uint8_t type_obj, lean_obj_arg w)
{
    int family = address_family_unbox(af_obj);
    int type = sock_type_unbox(type_obj);
    SOCKET *socket_fd = malloc(sizeof(SOCKET));
    *socket_fd = socket(family, type, 0);
    if (ISVALIDSOCKET(*socket_fd))
    {
        return lean_io_result_mk_ok(socket_box(socket_fd));
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
    if (CLOSESOCKET(*socket_unbox(s)) == 0)
    {
        return lean_io_result_mk_ok(lean_box(0));
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

/**
 * constant Socket.connect (s : @& Socket) (a : @& SockAddr) : IO Unit
 */
lean_obj_res lean_socket_connect(b_lean_obj_arg s, b_lean_obj_arg a, lean_obj_arg w)
{
    sockaddr_len *sa = sockaddr_len_unbox(a);
    if (connect(*socket_unbox(s), (sockaddr *)&(sa->address), sa->address_len) == 0)
    {
        return lean_io_result_mk_ok(lean_box(0));
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

/**
 * constant Socket.bind (s : @& Socket) (a : @& SockAddr) : IO Unit
 */
lean_obj_res lean_socket_bind(b_lean_obj_arg s, b_lean_obj_arg a, lean_obj_arg w)
{
    sockaddr_len *sa = sockaddr_len_unbox(a);
    if (bind(*socket_unbox(s), (sockaddr *)&(sa->address), sa->address_len) == 0)
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
    if (listen(*socket_unbox(s), (int)n) == 0)
    {
        return lean_io_result_mk_ok(lean_box(0));
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

/**
 * constant Socket.accept (s : @& Socket) : IO (SockAddr × Socket)
 */
lean_obj_res lean_socket_accept(b_lean_obj_arg s, lean_obj_arg w)
{
    sockaddr_len *sal = malloc(sizeof(sockaddr_len));
    SOCKET *new_fd = malloc(sizeof(SOCKET));
    sal->address_len = sizeof(sockaddr);
    *new_fd = accept(*socket_unbox(s), (sockaddr *)(&(sal->address)), &(sal->address_len));
    if (ISVALIDSOCKET(*new_fd))
    {
        // printf("%d\n", sal->address_len);
        lean_object *o = lean_alloc_ctor(0, 2, 0);
        lean_ctor_set(o, 0, sockaddr_len_box(sal));
        lean_ctor_set(o, 1, socket_box(new_fd));
        return lean_io_result_mk_ok(o);
    }
    else
    {
        printf("fail\n");
        return lean_io_result_mk_error(get_socket_error());
    }
}

/**
 * constant Socket.shutdown (s : @& Socket) (h : ShutdownHow) : IO Unit 
 */
lean_obj_res lean_socket_shutdown(b_lean_obj_arg s, uint8_t h, lean_obj_arg w)
{
    if (listen(*socket_unbox(s), h))
    {
        return lean_io_result_mk_ok(lean_box(0));
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

/**
 * constant Socket.send (s : @& Socket) (b : @& ByteArray) : IO USize
 */
lean_obj_res lean_socket_send(b_lean_obj_arg s, b_lean_obj_arg b, lean_obj_arg w)
{
    lean_sarray_object *arr = lean_to_sarray(b);
    ssize_t bytes = send(*socket_unbox(s), arr->m_data, arr->m_size, 0);
    if (bytes >= 0)
    {
        return lean_io_result_mk_ok(lean_box_usize(bytes));
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

/**
 * constant Socket.sendto (s : @& Socket) (b : @& ByteArray) (a : @& SockAddr) : IO USize
 */
lean_obj_res lean_socket_sendto(b_lean_obj_arg s, b_lean_obj_arg b, b_lean_obj_arg a, lean_obj_arg w)
{
    lean_sarray_object *arr = lean_to_sarray(b);
    sockaddr_len *sal = sockaddr_len_unbox(a);
    ssize_t bytes = sendto(*socket_unbox(s), arr->m_data, arr->m_size, 0, (sockaddr *)&(sal->address), sal->address_len);
    if (bytes >= 0)
    {
        return lean_io_result_mk_ok(lean_box_usize(bytes));
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

/**
 * constant Socket.recv (s : @& Socket) (n : @& USize) : IO ByteArray
 */
lean_obj_res lean_socket_recv(b_lean_obj_arg s, size_t n, lean_obj_arg w)
{
    lean_object *arr = lean_alloc_sarray(1, 0, n);
    ssize_t bytes = recv(*socket_unbox(s), lean_sarray_cptr(arr), n, 0);
    if (bytes >= 0)
    {
        lean_to_sarray(arr)->m_size = bytes;
        return lean_io_result_mk_ok(arr);
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

/**
 * constant Socket.recvfrom (s : @& Socket) (n : @& USize) : IO (SockAddr × ByteArray)
 */
lean_obj_res lean_socket_recvfrom(b_lean_obj_arg s, size_t n, lean_obj_arg w)
{
    sockaddr_len *sal = malloc(sizeof(sockaddr_len));
    lean_object *arr = lean_alloc_sarray(1, 0, n);
    ssize_t bytes = recvfrom(*socket_unbox(s), lean_sarray_cptr(arr), n, 0, (sockaddr *)&(sal->address), &(sal->address_len));
    if (bytes >= 0)
    {
        lean_to_sarray(arr)->m_size = bytes;
        lean_object *o = lean_alloc_ctor(0, 2, 0);
        lean_ctor_set(o, 0, sockaddr_len_box(sal));
        lean_ctor_set(o, 1, arr);
        return lean_io_result_mk_ok(arr);
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

/**
 * constant Socket.peer (s : @& Socket) : IO SockAddr
 */
lean_obj_res lean_socket_peer(b_lean_obj_arg s, lean_obj_arg w)
{
    sockaddr_len *sal = malloc(sizeof(sockaddr_len));
    int status = getpeername(*socket_unbox(s), (sockaddr *)&(sal->address), &(sal->address_len));
    if (status == 0)
    {
        return lean_io_result_mk_ok(sockaddr_len_box(sal));
    }
    else
    {
        return lean_io_result_mk_error(get_socket_error());
    }
}

// ## SockAddr

/**
 * constant mk
  (host : @& String)
  (port : @& String)
  (family : AddressFamily := AddressFamily.unspecified)
  (type : SockType := SockType.unspecified)
  : IO SockAddr
 */
lean_obj_res lean_sockaddr_mk(b_lean_obj_arg h, b_lean_obj_arg p, uint8_t f, uint8_t t, lean_obj_arg w)
{
    const char *host = lean_string_cstr(h);
    const char *port = lean_string_cstr(p);
    int family = address_family_unbox(f);
    int type = sock_type_unbox(t);
    addrinfo hints;
    addrinfo *ai_res;
    memset(&hints, 0, sizeof hints);
    hints.ai_family = family;
    hints.ai_socktype = type;
    sockaddr_len *sal = malloc(sizeof(sockaddr_len));
    int status = getaddrinfo(host, port, &hints, &ai_res);
    if (status < 0)
    {
#ifdef _WIN32
        int errnum = WSAGetLastError();
        wchar_t *s = NULL;
        FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                       NULL, errnum,
                       MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                       (LPWSTR)&s, 0, NULL);
        char *err_str;
        wcstombs(err_str, s, 100);
        lean_object *details = lean_mk_string(err_str);
        LocalFree(s);
#else
        lean_object *details = lean_mk_string(gai_strerror(status));
#endif
        return lean_io_result_mk_error(lean_mk_io_user_error(details));
    }
    sal->address_len = ai_res->ai_addrlen;
    sal->address = *(sockaddr_storage *)(ai_res->ai_addr);
    freeaddrinfo(ai_res);
    return lean_io_result_mk_ok(sockaddr_len_box(sal));
}

/**
 * constant Sock.family (a : @&SockAddr) : Option AddressFamily
 */
lean_obj_res lean_sockaddr_family(b_lean_obj_arg a, lean_obj_arg w)
{
    switch (sockaddr_len_unbox(a)->address.ss_family)
    {
    case AF_UNSPEC:
        return lean_option_mk_some(lean_box(0));
    case AF_INET:
        return lean_option_mk_some(lean_box(1));
    case AF_INET6:
        return lean_option_mk_some(lean_box(2));
    default:
        return lean_option_mk_none();
    }
}

/**
 * constant Sock.port (a : @&SockAddr) : Option UInt16
 */
lean_obj_res lean_sockaddr_port(b_lean_obj_arg a, lean_obj_arg w)
{
    lean_object *o;
    sockaddr_len *sa = sockaddr_len_unbox(a);
    if (sa->address.ss_family == AF_INET)
    {
        o = lean_alloc_ctor(1, 1, 0);
        lean_ctor_set(o, 0, lean_box(ntohs(((sockaddr_in *)&(sa->address))->sin_port)));
    }
    else if (sa->address.ss_family == AF_INET6)
    {
        o = lean_alloc_ctor(1, 1, 0);
        lean_ctor_set(o, 0, lean_box(ntohs(((sockaddr_in6 *)&(sa->address))->sin6_port)));
    }
    else
    {
        o = lean_alloc_ctor(0, 0, 0);
    }
    return o;
}

/**
 * constant SockAddr.host (a : @&SockAddr) : Option String
 */
lean_obj_res lean_sockaddr_host(b_lean_obj_arg a, lean_obj_arg w)
{
    lean_object *o;
    sockaddr_len *sa = sockaddr_len_unbox(a);
    if (sa->address.ss_family == AF_INET)
    {
        char ip4[INET_ADDRSTRLEN];
        inet_ntop(AF_INET, &(((sockaddr_in *)&(sa->address))->sin_addr), ip4, INET_ADDRSTRLEN);
        o = lean_alloc_ctor(1, 1, 0);
        lean_ctor_set(o, 0, lean_mk_string(ip4));
    }
    else if (sa->address.ss_family == AF_INET6)
    {
        char ip6[INET6_ADDRSTRLEN];
        inet_ntop(AF_INET6, &(((sockaddr_in6 *)&(sa->address))->sin6_addr), ip6, INET6_ADDRSTRLEN);
        o = lean_alloc_ctor(1, 1, 0);
        lean_ctor_set(o, 0, lean_mk_string(ip6));
    }
    else
    {
        o = lean_alloc_ctor(0, 0, 0);
    }
    return o;
}

// ## Other Functions

/**
 * constant hostName : IO String
 */
lean_obj_res lean_gethostname()
{
    char buffer[100];
    int status = gethostname(buffer, 100);
    if (status < 0)
    {
        return lean_io_result_mk_error(get_socket_error());
    }
    return lean_io_result_mk_ok(lean_mk_string(buffer));
}