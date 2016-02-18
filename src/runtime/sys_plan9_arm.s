// Copyright 2010 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#include "go_asm.h"
#include "go_tls.h"
#include "textflag.h"

// setldt(int entry, int address, int limit)
TEXT runtime·setldt(SB),NOSPLIT,$0
	RET

TEXT runtime·open(SB),NOSPLIT,$0
	MOVW    $14, R0
	SWI $64
	MOVW	R0, ret+12(FP)
	RET

TEXT runtime·pread(SB),NOSPLIT,$0
	MOVW    $50, R0
	SWI $64
	MOVW	R0, ret+20(FP)
	RET

TEXT runtime·pwrite(SB),NOSPLIT,$0
	MOVW    $51, R0
	SWI $64
	MOVW	R0, ret+20(FP)
	RET

// int32 _seek(int64*, int32, int64, int32)
TEXT _seek<>(SB),NOSPLIT,$0
    MOVW $39, R0
    SWI $64
	RET

TEXT runtime·seek(SB),NOSPLIT,$24
	//MOVW ret+16(FP), R0
	MOVW	fd+0(FP), R1
	MOVW	offset_lo+4(FP), R2
	MOVW	offset_hi+8(FP), R3
	MOVW	whence+12(FP), R4
    MOVW    R0, 0(R13)
	MOVW	R1, 4(R13)
	MOVW	R2, 8(R13)
	MOVW	R3, 12(R13)
	MOVW	R4, 16(R13)
	CALL	_seek<>(SB)
	//CMPW	R0, $0
	//JGE	3(PC)
    //MOVW $-1, ret+16(FP)
    //MOVW $-1, ret+20(FP)
	//MOVW	$-1, ret_lo+16(FP)
	//MOVW	$-1, ret_hi+20(FP)
	RET

TEXT runtime·closefd(SB),NOSPLIT,$0
	MOVW    $4, R0
	SWI $64
	MOVW	R0, ret+4(FP)
	RET

TEXT runtime·exits(SB),NOSPLIT,$0
	MOVW    $8, R0
	SWI $64
	RET

TEXT runtime·brk_(SB),NOSPLIT,$0
	MOVW    $24, R0
	SWI $64
	MOVW	R0, ret+4(FP)
	RET

TEXT runtime·sleep(SB),NOSPLIT,$0
	MOVW    $17, R0
	SWI $64
	MOVW	R0, ret+4(FP)
	RET

TEXT runtime·plan9_semacquire(SB),NOSPLIT,$0
	MOVW    $37, R0
	SWI $64
	MOVW	R0, ret+8(FP)
	RET

TEXT runtime·plan9_tsemacquire(SB),NOSPLIT,$0
	MOVW    $52, R0
	SWI $64
	MOVW	R0, ret+8(FP)
	RET

TEXT nsec<>(SB),NOSPLIT,$0
	MOVW    $53, R0
	SWI $64
	MOVW	R0, ret+8(FP)
	RET

TEXT runtime·nsec(SB),NOSPLIT,$8
    MOVW $0, R0
    RET

//	MOVW	ret+4(FP), R0
//	MOVW	R0, 0(R13)
//	CALL	nsec<>(SB)
	//CMPL	R0, $0
	//JGE	3(PC)
	//MOVW	$-1, ret_lo+4(FP)
	//MOVW	$-1, ret_hi+8(FP)
//	RET

// func now() (sec int64, nsec int32)
TEXT time·now(SB),NOSPLIT,$8-12
	CALL	runtime·nanotime(SB)
	//MOVW	0(R13), R0
	//MOVW	4(R13), R4

	//MOVW	$1000000000, R3
	//DIVW	R2
	//MOVW	R0, sec+0(FP)
	//MOVW	$0, sec+4(FP)
	//MOVW	R4, nsec+8(FP)
	RET

TEXT runtime·notify(SB),NOSPLIT,$0
	MOVW    $28, R0
	SWI $64
	MOVW	R0, ret+4(FP)
	RET

TEXT runtime·noted(SB),NOSPLIT,$0
	MOVW    $29, R0
	SWI $64
	MOVW	R0, ret+8(FP)
	RET
	
TEXT runtime·plan9_semrelease(SB),NOSPLIT,$0
	MOVW    $38, R0
	SWI $64
	MOVW	R0, ret+8(FP)
	RET

TEXT runtime·rfork(SB),NOSPLIT,$0
	MOVW    $19, R0
	SWI $64
	MOVW	R0, ret+4(FP)
	RET

TEXT runtime·tstart_plan9(SB),NOSPLIT,$0
    MOVW m_g0(R0), g
    MOVW R0, g_m(g)
    BL runtime·emptyfunc(SB) // fault if stack check is wrong
    BL runtime·mstart(SB)

    MOVW $2, R8 // crash (not reached)
    MOVW R8, (R8)
    RET
	//MOVW	newm+0(FP), R2
	//MOVW	m_g0(R2), R3

	// Layout new m scheduler stack on os stack.
	//MOVW	R13, R0
	//MOVW	R0, (g_stack+stack_hi)(g)
	//SUB	$(64*1024), R0		// stack size
	//MOVW	R0, (g_stack+stack_lo)(g)
	//MOVW	R0, g_stackguard0(g)
	//MOVW	R0, g_stackguard1(g)

	// Initialize procid from TOS struct.
	//MOVW	_tos(SB), R0
	//MOVW	48(R0), R0
	//MOVW	R0, m_procid(R3)	// save pid as m->procid

	// Finally, initialize g.
	//get_tls(R1)
	//MOVW	R3, g(R1)

    //Arm doesn't have stackcheck
	//CALL	runtime·stackcheck(SB)
//  	CALL	runtime·mstart(SB)

	//MOVW	$0x1234, 0x1234		// not reached
	//RET

// void sigtramp(void *ureg, int8 *note)
TEXT runtime·sigtramp(SB),NOSPLIT,$0
	// check that g exists
	MOVW	g_m(R0), R0
	CMP	    $0, R0
	B.NE	3(PC)
	CALL	runtime·badsignal2(SB) // will exit
	RET

	// save args
	MOVW	ureg+4(SP), R2
	MOVW	note+8(SP), R3

	// change stack
	MOVW	g_m(R1), R1
	MOVW	m_gsignal(R2), R4
	MOVW	(g_stack+stack_hi)(R4), R4
	MOVW	R4, R13

	// make room for args and g
	SUB	$24, R13

	// save g
	MOVW	g_m(R0), R4
	MOVW	R4, 20(R13)

	// g = m->gsignal
	MOVW	m_gsignal(R1), R5
	MOVW	R5, g_m(R0)

	// load args and call sighandler
	MOVW	R2, 0(R13)
	MOVW	R3, 4(R13)
	MOVW	R4, 8(R13)

	CALL	runtime·sighandler(SB)
	MOVW	12(R13), R0

	// restore g
	MOVW	20(R13), R4
	MOVW	R4, g_m(R0)

	MOVW	R0, 0(R13)
	CALL	runtime·noted(SB)
	RET

// Only used by the 64-bit runtime.
TEXT runtime·setfpmasks(SB),NOSPLIT,$0
	RET

#define ERRMAX 128	/* from os_plan9.h */

// void errstr(int8 *buf, int32 len)
TEXT errstr<>(SB),NOSPLIT,$0
	MOVW    $41, R0
	SWI     $64
	RET

// func errstr() string
// Only used by package syscall.
// Grab error string due to a syscall made
// in entersyscall mode, without going
// through the allocator (issue 4994).
// See ../syscall/asm_plan9_386.s:/·Syscall/
TEXT runtime·errstr(SB),NOSPLIT,$8-8
	//get_tls(AX)
	//MOVL	g(AX), BX
	//MOVL	g_m(BX), BX
	//MOVL	(m_mOS+mOS_errstr)(BX), CX
	//MOVL	CX, 0(SP)
	//MOVL	$ERRMAX, 4(SP)
	CALL	errstr<>(SB)
	CALL	runtime·findnull(SB)
	//MOVL	4(SP), AX
	//MOVL	AX, ret_len+4(FP)
	//MOVL	0(SP), AX
	//MOVL	AX, ret_base+0(FP)
	RET

TEXT runtime·read_tls_fallback(SB),NOSPLIT,$-4
    RET
	//MOVW	$0xffff0fe0, R0
	//B	(R0)

TEXT ·publicationBarrier(SB),NOSPLIT,$-4-0
    RET
	//B	runtime·armPublicationBarrier(SB)
