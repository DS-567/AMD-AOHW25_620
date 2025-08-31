
main.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <__crt0_entry>:
   0:	000020b7          	lui	ra,0x2
   4:	80008093          	addi	ra,ra,-2048 # 1800 <__etext+0x1630>
   8:	30009073          	csrw	mstatus,ra
   c:	00000097          	auipc	ra,0x0
  10:	12808093          	addi	ra,ra,296 # 134 <__crt0_trap_handler>
  14:	30509073          	csrw	mtvec,ra
  18:	30401073          	csrw	mie,zero

0000001c <__crt0_pointer_init>:
  1c:	80002217          	auipc	tp,0x80002
  20:	fe320213          	addi	tp,tp,-29 # 80001fff <__crt0_stack_end+0x0>
  24:	ffc27113          	andi	sp,tp,-4
  28:	80000297          	auipc	t0,0x80000
  2c:	7d828293          	addi	t0,t0,2008 # 80000800 <__crt0_stack_end+0xffffe801>
  30:	ffc2f193          	andi	gp,t0,-4

00000034 <__crt0_reg_file_init>:
  34:	00000313          	li	t1,0
  38:	00000393          	li	t2,0
  3c:	00000413          	li	s0,0
  40:	00000493          	li	s1,0
  44:	00000813          	li	a6,0
  48:	00000893          	li	a7,0
  4c:	00000913          	li	s2,0
  50:	00000993          	li	s3,0
  54:	00000a13          	li	s4,0
  58:	00000a93          	li	s5,0
  5c:	00000b13          	li	s6,0
  60:	00000b93          	li	s7,0
  64:	00000c13          	li	s8,0
  68:	00000c93          	li	s9,0
  6c:	00000d13          	li	s10,0
  70:	00000d93          	li	s11,0
  74:	00000e13          	li	t3,0
  78:	00000e93          	li	t4,0
  7c:	00000f13          	li	t5,0
  80:	00000f93          	li	t6,0

00000084 <__crt0_copy_data>:
  84:	1d000593          	li	a1,464
  88:	80000617          	auipc	a2,0x80000
  8c:	f7860613          	addi	a2,a2,-136 # 80000000 <__crt0_stack_end+0xffffe001>
  90:	80000697          	auipc	a3,0x80000
  94:	f7068693          	addi	a3,a3,-144 # 80000000 <__crt0_stack_end+0xffffe001>
  98:	00c58e63          	beq	a1,a2,b4 <__crt0_clear_bss>

0000009c <__crt0_copy_data_loop>:
  9c:	00d65c63          	bge	a2,a3,b4 <__crt0_clear_bss>
  a0:	0005a703          	lw	a4,0(a1)
  a4:	00e62023          	sw	a4,0(a2)
  a8:	00458593          	addi	a1,a1,4
  ac:	00460613          	addi	a2,a2,4
  b0:	fedff06f          	j	9c <__crt0_copy_data_loop>

000000b4 <__crt0_clear_bss>:
  b4:	80000717          	auipc	a4,0x80000
  b8:	f4c70713          	addi	a4,a4,-180 # 80000000 <__crt0_stack_end+0xffffe001>
  bc:	8b418793          	addi	a5,gp,-1868 # 800000b4 <__BSS_END__>

000000c0 <__crt0_clear_bss_loop>:
  c0:	00f75863          	bge	a4,a5,d0 <__crt0_call_constructors>
  c4:	00072023          	sw	zero,0(a4)
  c8:	00470713          	addi	a4,a4,4
  cc:	ff5ff06f          	j	c0 <__crt0_clear_bss_loop>

000000d0 <__crt0_call_constructors>:
  d0:	00000417          	auipc	s0,0x0
  d4:	10040413          	addi	s0,s0,256 # 1d0 <__etext>
  d8:	00000497          	auipc	s1,0x0
  dc:	0f848493          	addi	s1,s1,248 # 1d0 <__etext>

000000e0 <__crt0_call_constructors_loop>:
  e0:	00945a63          	bge	s0,s1,f4 <__crt0_call_constructors_loop_end>
  e4:	00042083          	lw	ra,0(s0)
  e8:	000080e7          	jalr	ra
  ec:	00440413          	addi	s0,s0,4
  f0:	ff1ff06f          	j	e0 <__crt0_call_constructors_loop>

000000f4 <__crt0_call_constructors_loop_end>:
  f4:	00000513          	li	a0,0
  f8:	00000593          	li	a1,0
  fc:	078000ef          	jal	ra,174 <main>

00000100 <__crt0_main_exit>:
 100:	30401073          	csrw	mie,zero
 104:	34051073          	csrw	mscratch,a0

00000108 <__crt0_call_destructors>:
 108:	00000417          	auipc	s0,0x0
 10c:	0c840413          	addi	s0,s0,200 # 1d0 <__etext>
 110:	00000497          	auipc	s1,0x0
 114:	0c048493          	addi	s1,s1,192 # 1d0 <__etext>

00000118 <__crt0_call_destructors_loop>:
 118:	00945a63          	bge	s0,s1,12c <__crt0_call_destructors_loop_end>
 11c:	00042083          	lw	ra,0(s0)
 120:	000080e7          	jalr	ra
 124:	00440413          	addi	s0,s0,4
 128:	ff1ff06f          	j	118 <__crt0_call_destructors_loop>

0000012c <__crt0_call_destructors_loop_end>:
 12c:	10500073          	wfi
 130:	ffdff06f          	j	12c <__crt0_call_destructors_loop_end>

00000134 <__crt0_trap_handler>:
 134:	34041073          	csrw	mscratch,s0
 138:	34202473          	csrr	s0,mcause
 13c:	01f45413          	srli	s0,s0,0x1f
 140:	02041663          	bnez	s0,16c <__crt0_trap_handler_end>
 144:	34102473          	csrr	s0,mepc
 148:	00440413          	addi	s0,s0,4
 14c:	34141073          	csrw	mepc,s0
 150:	34a02473          	csrr	s0,0x34a
 154:	00347413          	andi	s0,s0,3
 158:	ffd40413          	addi	s0,s0,-3
 15c:	00040863          	beqz	s0,16c <__crt0_trap_handler_end>
 160:	34102473          	csrr	s0,mepc
 164:	ffe40413          	addi	s0,s0,-2
 168:	34141073          	csrw	mepc,s0

0000016c <__crt0_trap_handler_end>:
 16c:	34002473          	csrr	s0,mscratch
 170:	30200073          	mret

00000174 <main>:
}

int main() {

    // call fibonacci series function to calculate first 45 values
    fibonacci(work_array, NUMS-1);
 174:	80000537          	lui	a0,0x80000
int main() {
 178:	ff010113          	addi	sp,sp,-16
    fibonacci(work_array, NUMS-1);
 17c:	00050513          	mv	a0,a0
 180:	02c00593          	li	a1,44
int main() {
 184:	00112623          	sw	ra,12(sp)
    fibonacci(work_array, NUMS-1);
 188:	014000ef          	jal	ra,19c <fibonacci>

    return 0;
}
 18c:	00c12083          	lw	ra,12(sp)
 190:	00000513          	li	a0,0
 194:	01010113          	addi	sp,sp,16
 198:	00008067          	ret

0000019c <fibonacci>:
    array[1] = 1;
 19c:	00100793          	li	a5,1
 1a0:	00f52223          	sw	a5,4(a0) # 80000004 <__crt0_stack_end+0xffffe005>
    array[0] = 0;
 1a4:	00052023          	sw	zero,0(a0)
    for (int i=2; i<=n; i++) {
 1a8:	00200793          	li	a5,2
 1ac:	00450513          	addi	a0,a0,4
 1b0:	00f5d463          	bge	a1,a5,1b8 <fibonacci+0x1c>
}
 1b4:	00008067          	ret
        array[i] = array[i-1] + array[i-2];
 1b8:	00052703          	lw	a4,0(a0)
 1bc:	ffc52683          	lw	a3,-4(a0)
    for (int i=2; i<=n; i++) {
 1c0:	00178793          	addi	a5,a5,1
        array[i] = array[i-1] + array[i-2];
 1c4:	00d70733          	add	a4,a4,a3
 1c8:	00e52223          	sw	a4,4(a0)
    for (int i=2; i<=n; i++) {
 1cc:	fe1ff06f          	j	1ac <fibonacci+0x10>
