package libuv

import "core:c"
import "core:mem"
import "core:net"

STATIC :: #config(STATIC, false)

when ODIN_OS == .Linux {
	foreign import lib {"./libuv.a" when STATIC else "system:uv"}
} else {
	foreign import lib "system:libuv"
}

File :: distinct c.int
DIR :: distinct rawptr

/* ENUMS */
Req_Type :: enum c.int {
	Unknown,
	Req,
	Connect,
	Write,
	Shutdown,
	UDP_Send,
	FS,
	Work,
	Get_Addr_Info,
	Et_Name_Info,
	Random,
	Req_Type_Max,
}

Fs_Type :: enum c.int {
	UNKNOWN = -1,
	CUSTOM,
	OPEN,
	CLOSE,
	READ,
	WRITE,
	SENDFILE,
	STAT,
	LSTAT,
	FSTAT,
	FTRUNCATE,
	UTIME,
	FUTIME,
	ACCESS,
	CHMOD,
	FCHMOD,
	FSYNC,
	FDATASYNC,
	UNLINK,
	RMDIR,
	MKDIR,
	MKDTEMP,
	RENAME,
	SCANDIR,
	LINK,
	SYMLINK,
	READLINK,
	CHOWN,
	FCHOWN,
	REALPATH,
	COPYFILE,
	LCHOWN,
	OPENDIR,
	READDIR,
	CLOSEDIR,
	STATFS,
	MKSTEMP,
	LUTIME,
}

Handle_Type :: enum c.int {
	Unknown = 0,
	Async,
	Check,
	FS_event,
	FS_poll,
	Handle,
	Idle,
	Named_Sipe,
	Poll,
	Prepare,
	Process,
	Stream,
	TCP,
	Timer,
	TTY,
	UDP,
	Signal,
	File,
	Handle_Type_Max,
}

TCP_Flags :: enum c.int {
	IPV6_Only  = 1,
	Reuse_Port = 2,
}

Loop_Option :: enum c.int {
	Loop_Block_Signal = 0,
	Metrics_Idle_Time,
	Loop_Use_IO_Uring_SQPoll,
}

Run_Mode :: enum c.int {
	Default = 0,
	Once,
	No_Wait,
}

Dir_Ent_Type :: enum c.int {
	Unknown,
	File,
	Dir,
	Link,
	Fifo,
	Socket,
	Char,
	Block,
}

/* STRUCTS */
Dir_Ent :: struct {
	name: string,
	type: Dir_Ent_Type,
}

Queue :: struct {
	next: ^Queue,
	prev: ^Queue,
}

Handle_Fields :: struct {
	data:        rawptr,
	loop:        ^Loop,
	handle_type: Handle_Type,
	close_cb:    Close_CB,
	u:           struct #raw_union {
		fd:       c.int,
		reserved: [4]rawptr,
	},
}

Stream_Fields :: struct {
	write_queue_size: c.size_t,
	alloc_cb:         Alloc_CB,
	read_cb:          Read_CB,
}

Req_Fields :: struct {
	data:     rawptr,
	req_type: Req,
	reserved: [6]rawptr,
}

Time_Spec :: struct {
	sec:  c.long,
	nsec: c.long,
}

Stat :: struct {
	dev:      c.uint64_t,
	mode:     c.uint64_t,
	nlink:    c.uint64_t,
	uid:      c.uint64_t,
	gid:      c.uint64_t,
	rdev:     c.uint64_t,
	ino:      c.uint64_t,
	size:     c.uint64_t,
	blksize:  c.uint64_t,
	blocks:   c.uint64_t,
	flags:    c.uint64_t,
	get:      c.uint64_t,
	atim:     Time_Spec,
	mtim:     Time_Spec,
	ctim:     Time_Spec,
	birthtim: Time_Spec,
}

Buf :: struct {
	base: cstring,
	len:  c.size_t,
}

// Handles
Loop :: struct {
	using _: Handle_Fields,
}

Handle :: distinct rawptr
Dir_T :: struct {
	dir_ents: [^]Dir_Ent,
	nentries: c.size_t,
	reserved: [4]rawptr,
	dir:      DIR,
}

Stream :: struct {
	using _:               Handle_Fields,
	using _:               Stream_Fields,
	connect:               ^Connect,
	shutdown:              ^Shutdown,
	watcher:               IO_T,
	write_queue:           Queue,
	write_completed_queue: Queue,
	connection_cb:         Connection_CB,
	delayed_error:         c.int,
	accepted_fd:           c.int,
	queued_fds:            rawptr,
}

Tcp :: struct {
	using _: Handle_Fields,
	using _: Stream_Fields,
}

Udp :: distinct rawptr
Pipe :: distinct rawptr
TTY :: distinct rawptr
Poll :: distinct rawptr
Timer :: distinct rawptr
Prepare :: distinct rawptr
Check :: distinct rawptr
Idle :: struct {
	using _: Handle_Fields,
	idle_cb: Idle_CB,
	queue:   Queue,
}
Async :: distinct rawptr
Process :: distinct rawptr
FS_Event :: distinct rawptr
FS_Poll :: distinct rawptr
Signal :: distinct rawptr

// Request Types
Req :: distinct rawptr
Get_Addr_Info :: distinct rawptr
Get_Name_Info :: distinct rawptr
Shutdown :: distinct rawptr
Write :: distinct rawptr

Connect :: struct {
	using _: Req_Fields,
	cb:      Connect_CB,
	handle:  ^Stream,
	queue:   Queue,
}

UDP_Send :: distinct rawptr
FS :: struct {
	using _:  Req_Fields,
	type:     Fs_Type,
	loop:     ^Loop,
	fs_cb:    FS_CB,
	result:   c.ssize_t,
	ptr:      rawptr,
	path:     cstring,
	stat_buf: Stat,
	new_path: cstring,
	file:     File,
	flags:    c.int,
	mode:     c.uint,
	nbufs:    c.uint,
	bufs:     [^]Buf,
	off:      c.long,
	uid:      UID,
	gid:      UID,
	atime:    c.double,
	mtime:    c.double,
	work_req: Work,
	bufsml:   [4]Buf,
}

Work :: struct {
	work: proc "c" (w: ^Work),
	done: proc "c" (w: ^Work, status: c.int),
	loop: ^Loop,
	wq:   Queue,
}

Random :: distinct rawptr

// Other
Env_Item :: distinct rawptr
CPU_Info :: distinct rawptr
Interface_Address :: distinct rawptr
Passwd :: distinct rawptr
UTS_Name :: distinct rawptr
Stat_FS :: distinct rawptr
IO_T :: struct {
	bits:          c.uintptr_t,
	pending_queue: Queue,
	watcher_queue: Queue,
	pevents:       c.uint,
	events:        c.uint,
	fd:            c.int,
}

/* CALLBACKS */
Walk_CB :: #type proc "c" (handle: ^Handle)
Idle_CB :: #type proc "c" (handle: ^Idle)
Close_CB :: #type proc "c" (handle: ^Handle)
Alloc_CB :: #type proc "c" (handle: ^Handle, suggested_size: c.size_t, buf: ^Buf)
Read_CB :: #type proc "c" (stream: ^Stream, nread: c.ssize_t, buf: ^Buf)
Connect_CB :: #type proc "c" (req: ^Connect, status: c.int)
Connection_CB :: #type proc "c" (server: ^Stream, status: c.int)
FS_CB :: #type proc "c" (req: ^FS)

get_loop_ptr :: proc(allocator := context.allocator) -> (loop: ^Loop, err: mem.Allocator_Error) {
	size := cast(int)loop_size()
	loop_raw := mem.alloc(size, allocator = allocator) or_return
	loop = cast(^Loop)loop_raw
	return
}

@(default_calling_convention = "c", link_prefix = "uv_")
foreign lib {
	default_loop :: proc() -> ^Loop ---
	loop_init :: proc(loop: ^Loop) -> c.int ---
	loop_configure :: proc(loop: ^Loop, option: Loop_Option) -> c.int ---
	loop_alive :: proc(loop: ^Loop) -> c.int ---
	loop_size :: proc() -> c.size_t ---

	run :: proc(loop: ^Loop, mode: Run_Mode) -> c.int ---
	loop_close :: proc(loop: ^Loop) -> c.int ---


	idle_init :: proc(loop: ^Loop, idler: ^Idle) ---
	idle_start :: proc(idler: ^Idle, cb: Idle_CB) ---
	idle_stop :: proc(idler: ^Idle) ---

	fs_open :: proc(loop: ^Loop, req: ^FS, path: cstring, flags: c.int, mode: c.int, cb: FS_CB) -> c.int ---
	fs_close :: proc(loop: ^Loop, req: ^FS, file: File, cb: FS_CB) -> c.int ---
	fs_read :: proc(loop: ^Loop, req: ^FS, file: File, bufs: [^]Buf, nbufs: c.uint, offset: c.int64_t, cb: FS_CB) -> c.int ---
	fs_unlink :: proc(loop: ^Loop, req: ^FS, path: cstring, cb: FS_CB) -> c.int ---
	fs_write :: proc(loop: ^Loop, req: ^FS, file: File, bufs: [^]Buf, nbufs: c.uint, offset: c.int64_t, cb: FS_CB) -> c.int ---
	fs_copyfile :: proc(loop: ^Loop, req: ^FS, path: cstring, new_path: cstring, flags: c.int, cb: FS_CB) -> c.int ---
	fs_mkdir :: proc(loop: ^Loop, req: ^FS, path: cstring, mode: c.int, cb: FS_CB) -> c.int ---
	fs_mkdtemp :: proc(loop: ^Loop, req: ^FS, tpl: cstring, cb: FS_CB) -> c.int ---
	fs_mkstemp :: proc(loop: ^Loop, req: ^FS, tpl: cstring, cb: FS_CB) -> c.int ---
	fs_rmdir :: proc(loop: ^Loop, req: ^FS, path: cstring, cb: FS_CB) -> c.int ---
	fs_scandir :: proc(loop: ^Loop, req: ^FS, path: cstring, flags: c.int, cb: FS_CB) -> c.int ---
	fs_scandir_next :: proc(loop: ^Loop, req: ^FS, ent: ^Dir_Ent) -> c.int ---
	fs_opendir :: proc(loop: ^Loop, req: ^FS, path: cstring, cb: FS_CB) -> c.int ---
	fs_readdir :: proc(loop: ^Loop, req: ^FS, dir: ^Dir_T, cb: FS_CB) -> c.int ---
	fs_closedir :: proc(loop: ^Loop, req: ^FS, dir: ^Dir_T, cb: FS_CB) -> c.int ---
	fs_stat :: proc(loop: ^Loop, req: ^FS, path: cstring, cb: FS_CB) -> c.int ---
	fs_fstat :: proc(loop: ^Loop, req: ^FS, file: File, cb: FS_CB) -> c.int ---
	fs_rename :: proc(loop: ^Loop, req: ^FS, path: cstring, new_path: cstring, cb: FS_CB) -> c.int ---
	fs_fsync :: proc(loop: ^Loop, req: ^FS, file: File, cb: FS_CB) -> c.int ---
	fs_fdatasync :: proc(loop: ^Loop, req: ^FS, file: File, cb: FS_CB) -> c.int ---
	fs_ftruncate :: proc(loop: ^Loop, req: ^FS, file: File, offset: c.int64_t, cb: FS_CB) -> c.int ---
	fs_sendfile :: proc(loop: ^Loop, req: ^FS, out_fd: File, in_fd: File, in_offset: c.int64_t, length: c.size_t, cb: FS_CB) -> c.int ---
	fs_access :: proc(loop: ^Loop, req: ^FS, path: cstring, mode: c.int, cb: FS_CB) -> c.int ---
	fs_chmod :: proc(loop: ^Loop, req: ^FS, path: cstring, mode: c.int, cb: FS_CB) -> c.int ---
	fs_utime :: proc(loop: ^Loop, req: ^FS, path: cstring, atime: c.double, mtime: c.double, cb: FS_CB) -> c.int ---
	fs_futime :: proc(loop: ^Loop, req: ^FS, file: File, atime: c.double, mtime: c.double, cb: FS_CB) -> c.int ---
	fs_lutime :: proc(loop: ^Loop, req: ^FS, path: cstring, atime: c.double, mtime: c.double, cb: FS_CB) -> c.int ---
	fs_lstat :: proc(loop: ^Loop, req: ^FS, path: cstring, cb: FS_CB) -> c.int ---
	fs_link :: proc(loop: ^Loop, req: ^FS, path: cstring, new_path: cstring, cb: FS_CB) -> c.int ---
	fs_symlink :: proc(loop: ^Loop, req: ^FS, path: cstring, new_path: cstring, flags: c.int, cb: FS_CB) -> c.int ---
	fs_readlink :: proc(loop: ^Loop, req: ^FS, path: cstring, cb: FS_CB) -> c.int ---
	fs_realpath :: proc(loop: ^Loop, req: ^FS, path: cstring, cb: FS_CB) -> c.int ---
	fs_fchmod :: proc(loop: ^Loop, req: ^FS, file: File, mode: c.int, cb: FS_CB) -> c.int ---
	fs_chown :: proc(loop: ^Loop, req: ^FS, path: cstring, uid: UID, gid: GID, cb: FS_CB) -> c.int ---
	fs_fchown :: proc(loop: ^Loop, req: ^FS, file: File, uid: UID, gid: GID, cb: FS_CB) -> c.int ---
	fs_lchown :: proc(loop: ^Loop, req: ^FS, path: cstring, uid: UID, gid: GID, cb: FS_CB) -> c.int ---
	fs_statfs :: proc(loop: ^Loop, req: ^FS, path: cstring, cb: FS_CB) -> c.int ---


	tcp_init :: proc(loop: ^Loop, handle: ^Tcp) -> c.int ---
	tcp_init_ex :: proc(loop: ^Loop, handle: ^Tcp, flags: c.uint) -> c.int ---
	tcp_open :: proc(handle: ^Tcp, sock: c.int) -> c.int ---
	tcp_nodelay :: proc(handle: ^Tcp, enable: c.int) -> c.int ---
	tcp_keepalive :: proc(handle: ^Tcp, enable: c.int, delay: c.uint) -> c.int ---
	tcp_keepalive_ex :: proc(handle: ^Tcp, on: c.int, idle: c.uint, intvl: c.uint, cnt: c.uint) -> c.int ---
	tcp_simultaneous_accepts :: proc(handle: ^Tcp, enable: c.int) -> c.int ---
	tcp_bind :: proc(handle: ^Tcp, addr: ^Sock_Addr, name_len: ^c.int) -> c.int ---
	tcp_getsockname :: proc(handle: ^Tcp, name: ^Sock_Addr, name_len: ^c.int) -> c.int ---
	tcp_getpeername :: proc(handle: ^Tcp, name: ^Sock_Addr, name_len: ^c.int) -> c.int ---
	tcp_close_reset :: proc(handle: ^Tcp, close_cb: Close_CB) -> c.int ---
	tcp_connect :: proc(req: ^Connect, handle: ^Tcp, addr: ^Sock_Addr, cb: Connect_CB) -> c.int ---
}
