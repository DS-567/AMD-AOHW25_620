
main.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <__crt0_entry>:
   0:	000020b7          	lui	ra,0x2
   4:	80008093          	addi	ra,ra,-2048 # 1800 <__RODATA_END__+0x1334>
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
  84:	4cc00593          	li	a1,1228
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
  bc:	85018793          	addi	a5,gp,-1968 # 80000050 <__BSS_END__>

000000c0 <__crt0_clear_bss_loop>:
  c0:	00f75863          	bge	a4,a5,d0 <__crt0_call_constructors>
  c4:	00072023          	sw	zero,0(a4)
  c8:	00470713          	addi	a4,a4,4
  cc:	ff5ff06f          	j	c0 <__crt0_clear_bss_loop>

000000d0 <__crt0_call_constructors>:
  d0:	00000417          	auipc	s0,0x0
  d4:	3ac40413          	addi	s0,s0,940 # 47c <__etext>
  d8:	00000497          	auipc	s1,0x0
  dc:	3a448493          	addi	s1,s1,932 # 47c <__etext>

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
 10c:	37440413          	addi	s0,s0,884 # 47c <__etext>
 110:	00000497          	auipc	s1,0x0
 114:	36c48493          	addi	s1,s1,876 # 47c <__etext>

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
}

// Driver's code
int main()
{
 174:	ff010113          	addi	sp,sp,-16
 178:	00812423          	sw	s0,8(sp)

  // loop to copy start array from ROM to work array in RAM to be manipulated
  for(int j=0; j<20; j++){
    work_array[j] = start_array[j];
 17c:	80000437          	lui	s0,0x80000
 180:	05000613          	li	a2,80
 184:	47c00593          	li	a1,1148
 188:	00040513          	mv	a0,s0
{
 18c:	00112623          	sw	ra,12(sp)
    work_array[j] = start_array[j];
 190:	148000ef          	jal	ra,2d8 <memcpy>

  // find the array's length
  int size = sizeof(work_array) / sizeof(work_array[0]);

  // Function call
  heapSort(work_array, size);
 194:	00040513          	mv	a0,s0
 198:	01400593          	li	a1,20
 19c:	0a4000ef          	jal	ra,240 <heapSort>

  return 0;
  
}
 1a0:	00c12083          	lw	ra,12(sp)
 1a4:	00812403          	lw	s0,8(sp)
 1a8:	00000513          	li	a0,0
 1ac:	01010113          	addi	sp,sp,16
 1b0:	00008067          	ret

000001b4 <heapify>:
    int left = 2 * i + 1;
 1b4:	00161793          	slli	a5,a2,0x1
 1b8:	00178713          	addi	a4,a5,1
    int right = 2 * i + 2;
 1bc:	00278793          	addi	a5,a5,2
    if (left < N && arr[left] > arr[largest])
 1c0:	06b75c63          	bge	a4,a1,238 <heapify+0x84>
 1c4:	00271813          	slli	a6,a4,0x2
 1c8:	00261693          	slli	a3,a2,0x2
 1cc:	01050833          	add	a6,a0,a6
 1d0:	00d506b3          	add	a3,a0,a3
 1d4:	00082803          	lw	a6,0(a6)
 1d8:	0006a683          	lw	a3,0(a3)
 1dc:	0506de63          	bge	a3,a6,238 <heapify+0x84>
    if (right < N && arr[right] > arr[largest])
 1e0:	02b7cc63          	blt	a5,a1,218 <heapify+0x64>
 1e4:	00070793          	mv	a5,a4
    if (largest != i) {
 1e8:	04c78a63          	beq	a5,a2,23c <heapify+0x88>
        swap(&arr[i], &arr[largest]);
 1ec:	00279713          	slli	a4,a5,0x2
 1f0:	00e50733          	add	a4,a0,a4
 1f4:	00261613          	slli	a2,a2,0x2
 1f8:	00c50633          	add	a2,a0,a2
    *a = *b;
 1fc:	00072803          	lw	a6,0(a4)
    int temp = *a;
 200:	00062683          	lw	a3,0(a2)
    *a = *b;
 204:	01062023          	sw	a6,0(a2)
    *b = temp;
 208:	00d72023          	sw	a3,0(a4)
 20c:	00078613          	mv	a2,a5
 210:	fa5ff06f          	j	1b4 <heapify>
    if (right < N && arr[right] > arr[largest])
 214:	00060713          	mv	a4,a2
 218:	00279813          	slli	a6,a5,0x2
 21c:	00271693          	slli	a3,a4,0x2
 220:	01050833          	add	a6,a0,a6
 224:	00d506b3          	add	a3,a0,a3
 228:	00082803          	lw	a6,0(a6)
 22c:	0006a683          	lw	a3,0(a3)
 230:	fb06dae3          	bge	a3,a6,1e4 <heapify+0x30>
 234:	fb5ff06f          	j	1e8 <heapify+0x34>
 238:	fcb7cee3          	blt	a5,a1,214 <heapify+0x60>
}
 23c:	00008067          	ret

00000240 <heapSort>:
{
 240:	ff010113          	addi	sp,sp,-16
 244:	00912223          	sw	s1,4(sp)
    for (int i = N / 2 - 1; i >= 0; i--)
 248:	01f5d493          	srli	s1,a1,0x1f
 24c:	00b484b3          	add	s1,s1,a1
{
 250:	00812423          	sw	s0,8(sp)
 254:	01212023          	sw	s2,0(sp)
 258:	00112623          	sw	ra,12(sp)
 25c:	00050913          	mv	s2,a0
 260:	00058413          	mv	s0,a1
    for (int i = N / 2 - 1; i >= 0; i--)
 264:	4014d493          	srai	s1,s1,0x1
 268:	fff48493          	addi	s1,s1,-1
 26c:	0204d863          	bgez	s1,29c <heapSort+0x5c>
    for (int i = N - 1; i >= 0; i--) {
 270:	fff40493          	addi	s1,s0,-1 # 7fffffff <__crt0_stack_end+0xffffe000>
 274:	00241413          	slli	s0,s0,0x2
 278:	00890433          	add	s0,s2,s0
 27c:	ffc40413          	addi	s0,s0,-4
 280:	0204d863          	bgez	s1,2b0 <heapSort+0x70>
}
 284:	00c12083          	lw	ra,12(sp)
 288:	00812403          	lw	s0,8(sp)
 28c:	00412483          	lw	s1,4(sp)
 290:	00012903          	lw	s2,0(sp)
 294:	01010113          	addi	sp,sp,16
 298:	00008067          	ret
        heapify(arr, N, i);
 29c:	00048613          	mv	a2,s1
 2a0:	00040593          	mv	a1,s0
 2a4:	00090513          	mv	a0,s2
 2a8:	f0dff0ef          	jal	ra,1b4 <heapify>
 2ac:	fbdff06f          	j	268 <heapSort+0x28>
    *a = *b;
 2b0:	00042703          	lw	a4,0(s0)
    int temp = *a;
 2b4:	00092783          	lw	a5,0(s2)
        heapify(arr, i, 0);
 2b8:	00048593          	mv	a1,s1
    *a = *b;
 2bc:	00e92023          	sw	a4,0(s2)
    *b = temp;
 2c0:	00f42023          	sw	a5,0(s0)
        heapify(arr, i, 0);
 2c4:	00000613          	li	a2,0
 2c8:	00090513          	mv	a0,s2
 2cc:	ee9ff0ef          	jal	ra,1b4 <heapify>
    for (int i = N - 1; i >= 0; i--) {
 2d0:	fff48493          	addi	s1,s1,-1
 2d4:	fa9ff06f          	j	27c <heapSort+0x3c>

000002d8 <memcpy>:
 2d8:	00b547b3          	xor	a5,a0,a1
 2dc:	0037f793          	andi	a5,a5,3
 2e0:	00c508b3          	add	a7,a0,a2
 2e4:	06079463          	bnez	a5,34c <memcpy+0x74>
 2e8:	00300793          	li	a5,3
 2ec:	06c7f063          	bgeu	a5,a2,34c <memcpy+0x74>
 2f0:	00357793          	andi	a5,a0,3
 2f4:	00050713          	mv	a4,a0
 2f8:	06079a63          	bnez	a5,36c <memcpy+0x94>
 2fc:	ffc8f613          	andi	a2,a7,-4
 300:	40e606b3          	sub	a3,a2,a4
 304:	02000793          	li	a5,32
 308:	08d7ce63          	blt	a5,a3,3a4 <memcpy+0xcc>
 30c:	00058693          	mv	a3,a1
 310:	00070793          	mv	a5,a4
 314:	02c77863          	bgeu	a4,a2,344 <memcpy+0x6c>
 318:	0006a803          	lw	a6,0(a3)
 31c:	00478793          	addi	a5,a5,4
 320:	00468693          	addi	a3,a3,4
 324:	ff07ae23          	sw	a6,-4(a5)
 328:	fec7e8e3          	bltu	a5,a2,318 <memcpy+0x40>
 32c:	fff60793          	addi	a5,a2,-1
 330:	40e787b3          	sub	a5,a5,a4
 334:	ffc7f793          	andi	a5,a5,-4
 338:	00478793          	addi	a5,a5,4
 33c:	00f70733          	add	a4,a4,a5
 340:	00f585b3          	add	a1,a1,a5
 344:	01176863          	bltu	a4,a7,354 <memcpy+0x7c>
 348:	00008067          	ret
 34c:	00050713          	mv	a4,a0
 350:	05157863          	bgeu	a0,a7,3a0 <memcpy+0xc8>
 354:	0005c783          	lbu	a5,0(a1)
 358:	00170713          	addi	a4,a4,1
 35c:	00158593          	addi	a1,a1,1
 360:	fef70fa3          	sb	a5,-1(a4)
 364:	fee898e3          	bne	a7,a4,354 <memcpy+0x7c>
 368:	00008067          	ret
 36c:	0005c683          	lbu	a3,0(a1)
 370:	00170713          	addi	a4,a4,1
 374:	00377793          	andi	a5,a4,3
 378:	fed70fa3          	sb	a3,-1(a4)
 37c:	00158593          	addi	a1,a1,1
 380:	f6078ee3          	beqz	a5,2fc <memcpy+0x24>
 384:	0005c683          	lbu	a3,0(a1)
 388:	00170713          	addi	a4,a4,1
 38c:	00377793          	andi	a5,a4,3
 390:	fed70fa3          	sb	a3,-1(a4)
 394:	00158593          	addi	a1,a1,1
 398:	fc079ae3          	bnez	a5,36c <memcpy+0x94>
 39c:	f61ff06f          	j	2fc <memcpy+0x24>
 3a0:	00008067          	ret
 3a4:	ff010113          	addi	sp,sp,-16
 3a8:	00812623          	sw	s0,12(sp)
 3ac:	02000413          	li	s0,32
 3b0:	0005a383          	lw	t2,0(a1)
 3b4:	0045a283          	lw	t0,4(a1)
 3b8:	0085af83          	lw	t6,8(a1)
 3bc:	00c5af03          	lw	t5,12(a1)
 3c0:	0105ae83          	lw	t4,16(a1)
 3c4:	0145ae03          	lw	t3,20(a1)
 3c8:	0185a303          	lw	t1,24(a1)
 3cc:	01c5a803          	lw	a6,28(a1)
 3d0:	0205a683          	lw	a3,32(a1)
 3d4:	02470713          	addi	a4,a4,36
 3d8:	40e607b3          	sub	a5,a2,a4
 3dc:	fc772e23          	sw	t2,-36(a4)
 3e0:	fe572023          	sw	t0,-32(a4)
 3e4:	fff72223          	sw	t6,-28(a4)
 3e8:	ffe72423          	sw	t5,-24(a4)
 3ec:	ffd72623          	sw	t4,-20(a4)
 3f0:	ffc72823          	sw	t3,-16(a4)
 3f4:	fe672a23          	sw	t1,-12(a4)
 3f8:	ff072c23          	sw	a6,-8(a4)
 3fc:	fed72e23          	sw	a3,-4(a4)
 400:	02458593          	addi	a1,a1,36
 404:	faf446e3          	blt	s0,a5,3b0 <memcpy+0xd8>
 408:	00058693          	mv	a3,a1
 40c:	00070793          	mv	a5,a4
 410:	02c77863          	bgeu	a4,a2,440 <memcpy+0x168>
 414:	0006a803          	lw	a6,0(a3)
 418:	00478793          	addi	a5,a5,4
 41c:	00468693          	addi	a3,a3,4
 420:	ff07ae23          	sw	a6,-4(a5)
 424:	fec7e8e3          	bltu	a5,a2,414 <memcpy+0x13c>
 428:	fff60793          	addi	a5,a2,-1
 42c:	40e787b3          	sub	a5,a5,a4
 430:	ffc7f793          	andi	a5,a5,-4
 434:	00478793          	addi	a5,a5,4
 438:	00f70733          	add	a4,a4,a5
 43c:	00f585b3          	add	a1,a1,a5
 440:	01176863          	bltu	a4,a7,450 <memcpy+0x178>
 444:	00c12403          	lw	s0,12(sp)
 448:	01010113          	addi	sp,sp,16
 44c:	00008067          	ret
 450:	0005c783          	lbu	a5,0(a1)
 454:	00170713          	addi	a4,a4,1
 458:	00158593          	addi	a1,a1,1
 45c:	fef70fa3          	sb	a5,-1(a4)
 460:	fee882e3          	beq	a7,a4,444 <memcpy+0x16c>
 464:	0005c783          	lbu	a5,0(a1)
 468:	00170713          	addi	a4,a4,1
 46c:	00158593          	addi	a1,a1,1
 470:	fef70fa3          	sb	a5,-1(a4)
 474:	fce89ee3          	bne	a7,a4,450 <memcpy+0x178>
 478:	fcdff06f          	j	444 <memcpy+0x16c>
