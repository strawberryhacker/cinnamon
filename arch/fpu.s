@ Copyright (C) StrawberryHacker

.syntax unified
.cpu cortex-a5
.arm

.global fpu_init
.type fpu_init, %function
fpu_init:
    @ Set both secure and non-secure access to FPU co-processors
    mrc p15, 0, r0, c1, c1, 2
    orr r0, r0, #(0b11 << 10)
    mcr p15, 0, r0, c1, c1, 2

    @ Enable kernel and user access to FPU co-processors
    ldr r0, =(0xF << 20)
    mcr p15, 0, r0, c1, c0, 2
    dsb
    isb

    bx lr

@ Performs the fully lazy FPU context switch
@
@ void fpu_context_switch(void)

.global fpu_context_switch
.type fpu_context_switch, %function
fpu_context_switch:
    stmdb sp!, {r4, lr}
    bl sched_get_lazy_fpu_user
    movs r4, r0                     @ Store the current lazy FPU user in r4

    @ 8 + 32 * 4 = 132 is the offset of the last FPU register. The register
    @ 32 is used because of the stmdb instruction
    addne r4, r4, #136              @ Get the FPU stack base
    vstmdbne r4!, {s0 - s31}        @ Stack the FPU registers

    @ Retrieve the next thread and unstack the VPF registers
    bl get_curr_thread
    mov r4, r0                      @ Store the current thread in r4
    add r4, r4, #8
    vldmia r4!, {s0 - s31}
    
    @ We have to update the next lazy FPU user to be the current thread
    bl sched_set_lazy_fpu_user      @ r0 already hold the current thread
    ldmia sp!, {r4, lr}
    bx lr
    