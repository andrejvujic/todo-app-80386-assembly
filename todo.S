.section .data
	# System calls
	SYS_EXIT = 1
	SYS_READ = 3
	SYS_WRITE = 4
	SYS_OPEN = 5
	SYS_CLOSE = 6
	SYS_NANOSLEEP = 162
	SYS_SOCKET = 359
	SYS_BIND = 361
	SYS_LISTEN = 363
	SYS_ACCEPT4 = 364
		
	STDOUT = 1
	
	AF_INET = 2
	SOCK_STREAM = 1
	PROTOCOL = 0
	PORT = 36895 # 14619
	INADDR_ANY = 0
	BACKLOG = 5 # How many connections can have in the queue
		
	
	MAX_REQUEST_LEN = 4096
	MAX_REQUEST_METHOD_LEN = 8
	MAX_REQUEST_PAYLOAD_KEY_LEN = 64
	MAX_REQUEST_PAYLOAD_VALUE_LEN = 256
	
	LINE_BREAK: .ascii "\n"
	LINE_BREAK_LEN = . - LINE_BREAK

	DATABASE_FILE_NAME: .ascii "database.txt\0"	
	MAX_DATABASE_LEN = 8192
	MAX_DATABASE_ELEMENT_LEN = 256
	database: .fill MAX_DATABASE_LEN, 1, 0
	database_len: .long 0
	database_element: .fill MAX_DATABASE_ELEMENT_LEN, 1, 0
	database_element_len: .long 0

	# File descriptors
	socket_fd: .long 0
	connection_fd: .long 0
	database_fd: .long 0
	
	# The following values are used when making sys_nanosleep calls
	# req_nanosleep - the amount of time the computer should sleep
	req_nanosleep:
		.long 1 # seconds
		.long 0 # nanoseconds
	# rem_nanosleep - the remaining sleeping time
	rem_nanosleep:
		.long 0
		.long 0
		
	# Server address and it's size
	s_addr:
		.fill 1, 2, 0
		.fill 1, 2, 0
		.fill 1, 4, 0
		.fill 1, 8, 0
	s_addr_size = . - s_addr
	
	# Client address and it's size
	c_addr:
		.fill 1, 2, 0
		.fill 1, 2, 0
		.fill 1, 4, 0
		.fill 1, 8, 0
	c_addr_size: .long . - c_addr
	
	GET: .ascii "GET\0"	
	POST: .ascii "POST\0"
	
	ADD_PAYLOAD_KEY: .ascii "todo\0"
	DELETE_PAYLOAD_KEY: .ascii "delete\0"
	
	# Incoming request and it's length
	r: .fill MAX_REQUEST_LEN, 1, 0
	r_len: .long 0
	
	r_method: .fill MAX_REQUEST_METHOD_LEN, 1, 0
	r_method_len: .long 0
	
	r_payload_key: .fill MAX_REQUEST_PAYLOAD_KEY_LEN, 1, 0
	r_payload_key_len: .long 0
	
	r_payload_value: .fill MAX_REQUEST_PAYLOAD_VALUE_LEN, 1, 0
	r_payload_value_len: .long 0
	
	starting: .ascii "[INFO] Starting web server...\n"
	starting_len = . - starting
	socket_trace: .ascii "[INFO] Creating a socket...\n"
	socket_trace_len = . - socket_trace
	bind_trace: .ascii "[INFO] Binding the socket...\n"
	bind_trace_len = . - bind_trace
	listen_trace: .ascii "[INFO] Listening to the socket...\n"
	listen_trace_len = . - listen_trace
	accept_trace: .ascii "[INFO] Waiting for client connections...\n"
	accept_trace_len = . - accept_trace
	ok: .ascii "[INFO] OK!\n"
	ok_len = . - ok
	
	# 200 OK - HTTP response header
	r200_header: .ascii "HTTP/1.1 200 OK\r\n"
		       	 .ascii "Content-Type: text/html\r\n"
		         .ascii "Connection: close\r\n"
		         .ascii "\r\n"	
	r200_header_len = . - r200_header
	
	# 405 METHOD NOT ALLOWED - HTTP response header
	r405_header: .ascii "HTTP/1.1 405 Method Not Allowed\r\n"
		       	 .ascii "Content-Type: text/plain\r\n"
		         .ascii "Connection: close\r\n"
		         .ascii "\r\n"
		         .ascii "405 Method Not Allowed"
	r405_header_len = . - r405_header
	
	html_form: .ascii "<form method=\"post\">"
			.ascii "<input required type=\"text\" name=\"todo\"></input>"
	      		.ascii "<input type=\"submit\" value=\"Add\"></input>"
	      		.ascii "</form>"
	html_form_len = . - html_form

	html_open_ol: .ascii "<ol>"
	html_open_ol_len = . - html_open_ol
	
	html_close_ol: .ascii "</ol>"
	html_close_ol_len = . - html_close_ol
	
	html_open_li: .ascii "<li>"
	html_open_li_len = . - html_open_li
	
	html_close_li: .ascii "</li>"
	html_close_li_len = . - html_close_li

	html_open_p: .ascii "<p>"
	html_open_p_len = . - html_open_p
	
	html_close_p: .ascii "</p>"
	html_close_p_len = . - html_close_p
	
.section .text

.macro sys_exit status_code
	movl $SYS_EXIT, %eax
	movl \status_code, %ebx
	int $0x80
.endm

.macro sys_write fd, buffer, buffer_size
	movl $SYS_WRITE, %eax
	movl \fd, %ebx
	movl \buffer, %ecx
	movl \buffer_size, %edx
	int $0x80
.endm

.macro sys_read fd, buffer, buffer_size
	movl $SYS_READ, %eax
	movl \fd, %ebx
	movl \buffer, %ecx
	movl \buffer_size, %edx
	int $0x80
.endm

# int socket(int domain, int type, int protocol);
.macro sys_socket domain, type, protocol
	movl $SYS_SOCKET, %eax
	movl \domain, %ebx
	movl \type, %ecx
	movl \protocol, %edx
	int $0x80
.endm

# int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
.macro sys_bind sock_fd, addr, addr_len
	movl $SYS_BIND, %eax
	movl \sock_fd, %ebx
	movl \addr, %ecx
	movl \addr_len, %edx
	int $0x80
.endm

# int listen(int sockfd, int backlog);
.macro sys_listen socket_fd, backlog
	movl $SYS_LISTEN, %eax
	movl \socket_fd, %ebx
	movl \backlog, %ecx
	int $0x80
.endm

# int accept4(int sockfd, struct sockaddr *addr, socklen_t *addrlen, int flags);
.macro sys_accept4 socket_fd, addr, addr_len, flags=$0
	movl $SYS_ACCEPT4, %eax
	movl \socket_fd, %ebx
	movl \addr, %ecx
	movl \addr_len, %edx
	movl \flags, %esi
	int $0x80
.endm

.macro sys_open_rwa name
	movl $SYS_OPEN, %eax
	movl \name, %ebx
	# RDWR = 2
	# O_APPEND = 1024
	# RDRW | O_APPEND = 1026 = 0x402
	movl $1026, %ecx 
	int $0x80
.endm

.macro sys_close fd
	movl $SYS_CLOSE, %eax
	movl \fd, %ebx
	int $0x80
.endm

.macro sys_nanosleep req, rem
	movl $SYS_NANOSLEEP, %eax
	movl \req, %ebx
	movl \rem, %ecx
	int $0x80
.endm

.macro extract_request_method r, method, method_len
	movl \r, %eax
	movl \method, %ebx

0:
	cmpb $' ', (%eax)
	je 1f
	movb (%eax), %cl
	movb %cl, (%ebx)
	incl \method_len
	
	incl %eax
	incl %ebx
	
	jmp 0b
1:
	movb $'\0', (%ebx)	
.endm

.macro check_string_equality string_1, string_2
	# This macro will put a 0 in %eax if the given strings are equal.
	# It will put a 1 in %eax if they aren't.
	movl $1, %eax
	movl \string_1, %ebx
	movl \string_2, %ecx

0:
	cmpb $'\0', (%ebx)
	je 1f
	
	movb (%ebx), %dl
	cmpb (%ecx), %dl
	jne 2f
	
	incl %ebx
	incl %ecx
	jmp 0b
	
1:
	movl $0, %eax
2:	
.endm

.global main
main:
	sys_write $STDOUT, $starting, $starting_len

	sys_write $STDOUT, $socket_trace, $socket_trace_len
	sys_socket $AF_INET, $SOCK_STREAM, $PROTOCOL
	movl %eax, socket_fd

	movw $AF_INET, s_addr
	movw $PORT, s_addr + 2
	movl $INADDR_ANY, s_addr + 4
	
	sys_write $STDOUT, $bind_trace, $bind_trace_len
	sys_bind socket_fd, $s_addr, $s_addr_size
	
	sys_write $STDOUT, $listen_trace, $listen_trace_len
	sys_listen socket_fd, $BACKLOG
	
next_request:
	sys_write $STDOUT, $accept_trace, $accept_trace_len
	
	sys_accept4 socket_fd, $c_addr, $c_addr_size
	movl %eax, connection_fd
	
	sys_read connection_fd, $r, $MAX_REQUEST_LEN
	movl %eax, r_len
	# The line below writes the entire request to the screen
	# sys_write $STDOUT, $r, r_len
	
	extract_request_method $r, $r_method, r_method_len
	
	check_string_equality $r_method, $GET
	cmpl $0, %eax
	je serve_GET_request
	
	check_string_equality $r_method, $POST
	cmpl $0, %eax
	je serve_POST_request

	jmp serve_405

serve_POST_request:
	movl $r, %eax
	addl r_len, %eax
	movb $'\0', (%eax)
	decl %eax

go_to_payload_start:
	cmpb $'\n', (%eax)
	je parse_payload_key
	decl %eax
	jmp go_to_payload_start

parse_payload_key:
	incl %eax
	movl $r_payload_key, %ebx
	movl $0, r_payload_key_len
	
parse_payload_key_loop:
	cmpb $'=', (%eax)
	je parse_payload_value
	movb (%eax), %cl
	movb %cl, (%ebx)
	incl %eax
	incl %ebx
	incl r_payload_key_len
	jmp parse_payload_key_loop

parse_payload_value:
	movb $'\0', (%ebx)
	
	incl %eax
	movl $r_payload_value, %ebx
	movl $0, r_payload_value_len
	
parse_payload_value_loop:
	cmpb $'\0', (%eax)
	je finalize_payload_parsing
	movb (%eax), %cl
	movb %cl, (%ebx)
	incl %eax
	incl %ebx
	incl r_payload_value_len
	jmp parse_payload_value_loop

finalize_payload_parsing:
	movb $'\0', (%ebx)
	sys_write $STDOUT, $r_payload_key, r_payload_key_len
	sys_write $STDOUT, $r_payload_value, r_payload_value_len
	
	check_string_equality $r_payload_key, $DELETE_PAYLOAD_KEY
	cmpl $0, %eax
	je delete_todo

	check_string_equality $r_payload_key, $ADD_PAYLOAD_KEY
	cmpl $0, %eax
	je add_todo
	
delete_todo:
	jmp serve_GET_request
	
add_todo:
	sys_open_rwa $DATABASE_FILE_NAME
	movl %eax, database_fd
	sys_write database_fd, $r_payload_value, r_payload_value_len
	sys_write database_fd, $LINE_BREAK, $LINE_BREAK_LEN
	sys_close database_fd
	
	jmp serve_GET_request
	
serve_GET_request:
	sys_write connection_fd, $r200_header, $r200_header_len
	sys_write connection_fd, $html_form, $html_form_len

	sys_open_rwa $DATABASE_FILE_NAME
	movl %eax, database_fd
	sys_read database_fd, $database, $MAX_DATABASE_LEN
	movl %eax, database_len
	sys_close database_fd
	
	sys_write connection_fd, $html_open_ol, $html_open_ol_len

	movl $database, %eax
	movl $database_element, %ebx
	movl $0, %edx
	movl $0, database_element_len
	
loop_through_database_elements:
	cmpl database_len, %edx
	je finalize_writing_elements_to_response
	
	cmpb $'\n', (%eax)
	jne skip_writing_element_to_response
	
	movl %eax, %esi
	movl %edx, %edi
		
	sys_write connection_fd, $html_open_li, $html_open_li_len
	sys_write connection_fd, $html_open_p, $html_open_p_len
	sys_write connection_fd, $database_element, database_element_len
	sys_write connection_fd, $html_close_p, $html_close_p_len
	sys_write connection_fd, $html_close_li, $html_close_li_len
	
	movl %esi, %eax
	movl %edi, %edx
	
	movl $database_element, %ebx
	movl $0, database_element_len
	jmp skip_to_next_element
	
skip_writing_element_to_response:
	movb (%eax), %cl
	movb %cl, (%ebx)
	
	incl %ebx
	incl database_element_len

skip_to_next_element:
	incl %eax
	incl %edx
	jmp loop_through_database_elements

finalize_writing_elements_to_response:
	sys_write connection_fd, $html_close_ol, $html_close_ol_len
	jmp close_client_connection
	
serve_405:
	sys_write connection_fd, $r405_header, $r405_header_len
	jmp close_client_connection
	
close_client_connection:
	sys_close connection_fd
	sys_nanosleep $req_nanosleep, $rem_nanosleep
	jmp next_request
	
	sys_close socket_fd	
	sys_write $STDOUT, $ok, $ok_len
end:
	sys_exit $0
