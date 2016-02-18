// Copyright 2013 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

/*
Input to cgo.

GOARCH=arm go tool cgo -cdefs defs_netbsd.go defs_netbsd_arm.go >defs_netbsd_arm.h
*/

package runtime

/*
#include <sys/types.h>
#include <machine/mcontext.h>
*/

const _PAGESIZE = 0x4000

type ureg struct {
	r0   uint32 /* general registers */
	r1   uint32 /* ... */
	r2   uint32 /* ... */
	r3   uint32
	r4   uint32 /* ... */
	r5   uint32 /* ... */
	r6   uint32 /* ... */
	r7   uint32 /* ... */
	r8   uint32 /* ... */
	r9   uint32 /* ... */
	r10  uint32 /* ... */
	r11  uint32 /* ... */
	r12  uint32 /* ... */
	r13  uint32 /* ... */
	r14  uint32 /* ... */
	r15  uint32 /* ... */
	cpsr uint32 /* ... */

	_type uint32
	error uint32 /* error code (or zero) */
	ip    uint32 /* pc */
	cs    uint32 /* old context */
	flags uint32 /* old flags */
	sp    uint32 /* sp */
	ss    uint32 /* old stack segment */

}

type sigctxt struct {
	u *ureg
}

func (c *sigctxt) pc() uintptr { return uintptr(c.u.r15) }
func (c *sigctxt) sp() uintptr { return uintptr(c.u.r13) }

func (c *sigctxt) setpc(x uintptr) { c.u.r15 = uint32(x) }
func (c *sigctxt) setsp(x uintptr) { c.u.r13 = uint32(x) }
func dumpregs(u *ureg) {
	print("r0    ", hex(u.r0), "\n")
	print("r1    ", hex(u.r1), "\n")
	print("r2    ", hex(u.r2), "\n")
	print("r3    ", hex(u.r3), "\n")
	print("r4    ", hex(u.r4), "\n")
	print("r5    ", hex(u.r5), "\n")
	print("r6    ", hex(u.r6), "\n")
	print("r7    ", hex(u.r7), "\n")
	print("r8    ", hex(u.r8), "\n")
	print("r9    ", hex(u.r9), "\n")
	print("r10    ", hex(u.r10), "\n")
	print("r11    ", hex(u.r11), "\n")
	print("r12    ", hex(u.r12), "\n")
	print("r13    ", hex(u.r13), "\n")
	print("r14    ", hex(u.r14), "\n")
	print("r15    ", hex(u.r15), "\n")
	print("ip", hex(u.ip), "\n")
	print("sp", hex(u.sp), "\n")
	//	print("flags ", hex(u.flags), "\n")
}
