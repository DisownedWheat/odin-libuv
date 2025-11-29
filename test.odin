package libuv

import "base:runtime"
import "core:log"
import "core:mem"
import "core:testing"
import "core:time"

start: time.Time

Ctx :: struct {
	ctx: runtime.Context,
}

@(test)
initial_test :: proc(t: ^testing.T) {
	start = time.now()

	wait_for_a_while :: proc "c" (handle: ^Idle) {
		state := cast(^Ctx)handle.data
		context = state.ctx

		diff := time.diff(start, time.now())
		if time.duration_seconds(diff) > 3 {
			idle_stop(handle)
		}
	}

	state := Ctx {
		ctx = context,
	}

	loop, _ := get_loop_ptr()
	loop_init(loop)
	log.info("Loop initialised")

	idler: Idle
	idler.data = &state
	idle_init(loop, &idler)
	log.info("Idler initialised")

	idle_start(&idler, wait_for_a_while)

	log.info("Idling...")

	run(loop, .Default)
	loop_close(loop)

	free(loop)
}
