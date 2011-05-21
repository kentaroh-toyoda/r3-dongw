
build/telosb/main.exe:     file format elf32-msp430


Disassembly of section .text:

00004000 <__init_stack>:
    4000:	31 40 00 39 	mov	#14592,	r1	;#0x3900

00004004 <__low_level_init>:
    4004:	b2 40 80 5a 	mov	#23168,	&0x0120	;#0x5a80
    4008:	20 01 

0000400a <__do_copy_data>:
    400a:	3f 40 02 00 	mov	#2,	r15	;#0x0002
    400e:	0f 93       	tst	r15		
    4010:	05 24       	jz	$+12     	;abs 0x401c
    4012:	2f 83       	decd	r15		
    4014:	9f 4f 38 4a 	mov	19000(r15),4352(r15);0x4a38(r15), 0x1100(r15)
    4018:	00 11 
    401a:	fb 23       	jnz	$-8      	;abs 0x4012

0000401c <__do_clear_bss>:
    401c:	3f 40 36 00 	mov	#54,	r15	;#0x0036
    4020:	0f 93       	tst	r15		
    4022:	04 24       	jz	$+10     	;abs 0x402c
    4024:	1f 83       	dec	r15		
    4026:	cf 43 02 11 	mov.b	#0,	4354(r15);r3 As==00, 0x1102(r15)
    402a:	fc 23       	jnz	$-6      	;abs 0x4024

0000402c <__jump_to_main>:
    402c:	30 40 56 46 	br	#0x4656	

00004030 <__ctors_end>:
    4030:	30 40 36 4a 	br	#0x4a36	

00004034 <__nesc_atomic_start>:
    4034:	0f 42       	mov	r2,	r15	
    4036:	32 c2       	dint			
    4038:	03 43       	nop			
    403a:	12 c3       	clrc			
    403c:	0f 10       	rrc	r15		
    403e:	0f 11       	rra	r15		
    4040:	0f 11       	rra	r15		
    4042:	5f f3       	and.b	#1,	r15	;r3 As==01
    4044:	30 41       	ret			

00004046 <__nesc_atomic_end>:
    4046:	4f 93       	tst.b	r15		
    4048:	01 24       	jz	$+4      	;abs 0x404c
    404a:	32 d2       	eint			
    404c:	30 41       	ret			

0000404e <Msp430TimerCapComP__0__Event__fired>:
    404e:	1f 42 62 01 	mov	&0x0162,r15	
    4052:	8f 10       	swpb	r15		
    4054:	5f f3       	and.b	#1,	r15	;r3 As==01
    4056:	02 24       	jz	$+6      	;abs 0x405c
    4058:	1f 42 72 01 	mov	&0x0172,r15	
    405c:	30 41       	ret			

0000405e <Msp430TimerCapComP__1__Event__fired>:
    405e:	1f 42 64 01 	mov	&0x0164,r15	
    4062:	8f 10       	swpb	r15		
    4064:	5f f3       	and.b	#1,	r15	;r3 As==01
    4066:	02 24       	jz	$+6      	;abs 0x406c
    4068:	1f 42 74 01 	mov	&0x0174,r15	
    406c:	30 41       	ret			

0000406e <Msp430TimerCapComP__2__Event__fired>:
    406e:	1f 42 66 01 	mov	&0x0166,r15	
    4072:	8f 10       	swpb	r15		
    4074:	5f f3       	and.b	#1,	r15	;r3 As==01
    4076:	02 24       	jz	$+6      	;abs 0x407c
    4078:	1f 42 76 01 	mov	&0x0176,r15	
    407c:	30 41       	ret			

0000407e <sig_TIMERA1_VECTOR>:
    407e:	0f 12       	push	r15		
    4080:	0e 12       	push	r14		
    4082:	0d 12       	push	r13		
    4084:	0c 12       	push	r12		
    4086:	1f 42 2e 01 	mov	&0x012e,r15	
    408a:	12 c3       	clrc			
    408c:	4f 10       	rrc.b	r15		
    408e:	5f 93       	cmp.b	#1,	r15	;r3 As==01
    4090:	08 24       	jz	$+18     	;abs 0x40a2
    4092:	4f 93       	tst.b	r15		
    4094:	03 24       	jz	$+8      	;abs 0x409c
    4096:	6f 93       	cmp.b	#2,	r15	;r3 As==10
    4098:	09 20       	jnz	$+20     	;abs 0x40ac
    409a:	06 3c       	jmp	$+14     	;abs 0x40a8
    409c:	b0 12 4e 40 	call	#0x404e	
    40a0:	05 3c       	jmp	$+12     	;abs 0x40ac
    40a2:	b0 12 5e 40 	call	#0x405e	
    40a6:	02 3c       	jmp	$+6      	;abs 0x40ac
    40a8:	b0 12 6e 40 	call	#0x406e	
    40ac:	3c 41       	pop	r12		
    40ae:	3d 41       	pop	r13		
    40b0:	3e 41       	pop	r14		
    40b2:	3f 41       	pop	r15		
    40b4:	b1 c0 f0 00 	bic	#240,	0(r1)	;#0x00f0, 0x0000(r1)
    40b8:	00 00 
    40ba:	00 13       	reti			

000040bc <SchedulerBasicP__TaskBasic__postTask>:
    40bc:	0b 12       	push	r11		
    40be:	4b 4f       	mov.b	r15,	r11	
    40c0:	b0 12 34 40 	call	#0x4034	
    40c4:	4e 4b       	mov.b	r11,	r14	
    40c6:	fe 93 04 11 	cmp.b	#-1,	4356(r14);r3 As==11, 0x1104(r14)
    40ca:	12 20       	jnz	$+38     	;abs 0x40f0
    40cc:	5e 42 37 11 	mov.b	&0x1137,r14	
    40d0:	4b 9e       	cmp.b	r14,	r11	
    40d2:	0e 24       	jz	$+30     	;abs 0x40f0
    40d4:	f2 93 36 11 	cmp.b	#-1,	&0x1136	;r3 As==11
    40d8:	05 20       	jnz	$+12     	;abs 0x40e4
    40da:	c2 4b 36 11 	mov.b	r11,	&0x1136	
    40de:	c2 4b 37 11 	mov.b	r11,	&0x1137	
    40e2:	0d 3c       	jmp	$+28     	;abs 0x40fe
    40e4:	7e f3       	and.b	#-1,	r14	;r3 As==11
    40e6:	ce 4b 04 11 	mov.b	r11,	4356(r14);0x1104(r14)
    40ea:	c2 4b 37 11 	mov.b	r11,	&0x1137	
    40ee:	07 3c       	jmp	$+16     	;abs 0x40fe
    40f0:	7b 40 05 00 	mov.b	#5,	r11	;#0x0005
    40f4:	b0 12 46 40 	call	#0x4046	
    40f8:	4f 4b       	mov.b	r11,	r15	
    40fa:	3b 41       	pop	r11		
    40fc:	30 41       	ret			
    40fe:	4b 43       	clr.b	r11		
    4100:	f9 3f       	jmp	$-12     	;abs 0x40f4

00004102 <Msp430TimerP__1__Timer__get>:
    4102:	1f 42 90 01 	mov	&0x0190,r15	
    4106:	3d 40 90 01 	mov	#400,	r13	;#0x0190
    410a:	2e 4d       	mov	@r13,	r14	
    410c:	0f 9e       	cmp	r14,	r15	
    410e:	02 24       	jz	$+6      	;abs 0x4114
    4110:	0f 4e       	mov	r14,	r15	
    4112:	fb 3f       	jmp	$-8      	;abs 0x410a
    4114:	30 41       	ret			

00004116 <TransformCounterC__0__Counter__get>:
    4116:	0b 12       	push	r11		
    4118:	0a 12       	push	r10		
    411a:	09 12       	push	r9		
    411c:	08 12       	push	r8		
    411e:	b0 12 34 40 	call	#0x4034	
    4122:	48 4f       	mov.b	r15,	r8	
    4124:	1a 42 10 11 	mov	&0x1110,r10	
    4128:	1b 42 12 11 	mov	&0x1112,r11	
    412c:	b0 12 02 41 	call	#0x4102	
    4130:	09 4f       	mov	r15,	r9	
    4132:	1f 42 80 01 	mov	&0x0180,r15	
    4136:	5f f3       	and.b	#1,	r15	;r3 As==01
    4138:	05 24       	jz	$+12     	;abs 0x4144
    413a:	1a 53       	inc	r10		
    413c:	0b 63       	adc	r11		
    413e:	b0 12 02 41 	call	#0x4102	
    4142:	09 4f       	mov	r15,	r9	
    4144:	4f 48       	mov.b	r8,	r15	
    4146:	b0 12 46 40 	call	#0x4046	
    414a:	0f 49       	mov	r9,	r15	
    414c:	12 c3       	clrc			
    414e:	0f 10       	rrc	r15		
    4150:	0f 11       	rra	r15		
    4152:	0f 11       	rra	r15		
    4154:	0f 11       	rra	r15		
    4156:	0f 11       	rra	r15		
    4158:	0c 4f       	mov	r15,	r12	
    415a:	0d 43       	clr	r13		
    415c:	0e 4a       	mov	r10,	r14	
    415e:	0f 4b       	mov	r11,	r15	
    4160:	4f ee       	xor.b	r14,	r15	
    4162:	0f ee       	xor	r14,	r15	
    4164:	8f 10       	swpb	r15		
    4166:	7e f3       	and.b	#-1,	r14	;r3 As==11
    4168:	8e 10       	swpb	r14		
    416a:	0e 5e       	rla	r14		
    416c:	0f 6f       	rlc	r15		
    416e:	0e 5e       	rla	r14		
    4170:	0f 6f       	rlc	r15		
    4172:	0e 5e       	rla	r14		
    4174:	0f 6f       	rlc	r15		
    4176:	0e dc       	bis	r12,	r14	
    4178:	0f dd       	bis	r13,	r15	
    417a:	38 41       	pop	r8		
    417c:	39 41       	pop	r9		
    417e:	3a 41       	pop	r10		
    4180:	3b 41       	pop	r11		
    4182:	30 41       	ret			

00004184 <TransformAlarmC__0__set_alarm>:
    4184:	0b 12       	push	r11		
    4186:	0a 12       	push	r10		
    4188:	09 12       	push	r9		
    418a:	08 12       	push	r8		
    418c:	b0 12 16 41 	call	#0x4116	
    4190:	0a 4e       	mov	r14,	r10	
    4192:	0b 4f       	mov	r15,	r11	
    4194:	1e 42 0c 11 	mov	&0x110c,r14	
    4198:	1f 42 0e 11 	mov	&0x110e,r15	
    419c:	0c 4e       	mov	r14,	r12	
    419e:	0d 4f       	mov	r15,	r13	
    41a0:	1c 52 08 11 	add	&0x1108,r12	
    41a4:	1d 62 0a 11 	addc	&0x110a,r13	
    41a8:	08 4a       	mov	r10,	r8	
    41aa:	09 4b       	mov	r11,	r9	
    41ac:	08 8e       	sub	r14,	r8	
    41ae:	09 7f       	subc	r15,	r9	
    41b0:	0b 28       	jnc	$+24     	;abs 0x41c8
    41b2:	08 4c       	mov	r12,	r8	
    41b4:	09 4d       	mov	r13,	r9	
    41b6:	08 8e       	sub	r14,	r8	
    41b8:	09 7f       	subc	r15,	r9	
    41ba:	10 28       	jnc	$+34     	;abs 0x41dc
    41bc:	0e 4a       	mov	r10,	r14	
    41be:	0f 4b       	mov	r11,	r15	
    41c0:	0e 8c       	sub	r12,	r14	
    41c2:	0f 7d       	subc	r13,	r15	
    41c4:	2b 2c       	jc	$+88     	;abs 0x421c
    41c6:	0a 3c       	jmp	$+22     	;abs 0x41dc
    41c8:	08 4c       	mov	r12,	r8	
    41ca:	09 4d       	mov	r13,	r9	
    41cc:	08 8e       	sub	r14,	r8	
    41ce:	09 7f       	subc	r15,	r9	
    41d0:	25 2c       	jc	$+76     	;abs 0x421c
    41d2:	0e 4a       	mov	r10,	r14	
    41d4:	0f 4b       	mov	r11,	r15	
    41d6:	0e 8c       	sub	r12,	r14	
    41d8:	0f 7d       	subc	r13,	r15	
    41da:	20 2c       	jc	$+66     	;abs 0x421c
    41dc:	0e 4c       	mov	r12,	r14	
    41de:	0f 4d       	mov	r13,	r15	
    41e0:	0e 8a       	sub	r10,	r14	
    41e2:	0f 7b       	subc	r11,	r15	
    41e4:	38 40 00 04 	mov	#1024,	r8	;#0x0400
    41e8:	09 43       	clr	r9		
    41ea:	08 8e       	sub	r14,	r8	
    41ec:	09 7f       	subc	r15,	r9	
    41ee:	18 2c       	jc	$+50     	;abs 0x4220
    41f0:	0c 4a       	mov	r10,	r12	
    41f2:	0d 4b       	mov	r11,	r13	
    41f4:	3c 50 00 04 	add	#1024,	r12	;#0x0400
    41f8:	0d 63       	adc	r13		
    41fa:	82 4c 0c 11 	mov	r12,	&0x110c	
    41fe:	82 4d 0e 11 	mov	r13,	&0x110e	
    4202:	0c 4e       	mov	r14,	r12	
    4204:	0d 4f       	mov	r15,	r13	
    4206:	3c 50 00 fc 	add	#-1024,	r12	;#0xfc00
    420a:	3d 63       	addc	#-1,	r13	;r3 As==11
    420c:	82 4c 08 11 	mov	r12,	&0x1108	
    4210:	82 4d 0a 11 	mov	r13,	&0x110a	
    4214:	3e 40 00 04 	mov	#1024,	r14	;#0x0400
    4218:	0f 43       	clr	r15		
    421a:	0a 3c       	jmp	$+22     	;abs 0x4230
    421c:	0e 43       	clr	r14		
    421e:	0f 43       	clr	r15		
    4220:	82 4c 0c 11 	mov	r12,	&0x110c	
    4224:	82 4d 0e 11 	mov	r13,	&0x110e	
    4228:	82 43 08 11 	mov	#0,	&0x1108	;r3 As==00
    422c:	82 43 0a 11 	mov	#0,	&0x110a	;r3 As==00
    4230:	0f 4e       	mov	r14,	r15	
    4232:	0f 5f       	rla	r15		
    4234:	0f 5f       	rla	r15		
    4236:	0f 5f       	rla	r15		
    4238:	0f 5f       	rla	r15		
    423a:	08 4f       	mov	r15,	r8	
    423c:	08 58       	rla	r8		
    423e:	b0 12 02 41 	call	#0x4102	
    4242:	0e 4a       	mov	r10,	r14	
    4244:	0e 5e       	rla	r14		
    4246:	0e 5e       	rla	r14		
    4248:	0e 5e       	rla	r14		
    424a:	0e 5e       	rla	r14		
    424c:	0e 5e       	rla	r14		
    424e:	0d 4f       	mov	r15,	r13	
    4250:	0d 8e       	sub	r14,	r13	
    4252:	0d 98       	cmp	r8,	r13	
    4254:	06 28       	jnc	$+14     	;abs 0x4262
    4256:	b0 12 02 41 	call	#0x4102	
    425a:	2f 53       	incd	r15		
    425c:	82 4f 92 01 	mov	r15,	&0x0192	
    4260:	0d 3c       	jmp	$+28     	;abs 0x427c
    4262:	08 8d       	sub	r13,	r8	
    4264:	38 90 03 00 	cmp	#3,	r8	;#0x0003
    4268:	06 2c       	jc	$+14     	;abs 0x4276
    426a:	b0 12 02 41 	call	#0x4102	
    426e:	2f 53       	incd	r15		
    4270:	82 4f 92 01 	mov	r15,	&0x0192	
    4274:	03 3c       	jmp	$+8      	;abs 0x427c
    4276:	08 5f       	add	r15,	r8	
    4278:	82 48 92 01 	mov	r8,	&0x0192	
    427c:	3f 40 82 01 	mov	#386,	r15	;#0x0182
    4280:	9f c3 00 00 	bic	#1,	0(r15)	;r3 As==01, 0x0000(r15)
    4284:	bf d0 10 00 	bis	#16,	0(r15)	;#0x0010, 0x0000(r15)
    4288:	00 00 
    428a:	38 41       	pop	r8		
    428c:	39 41       	pop	r9		
    428e:	3a 41       	pop	r10		
    4290:	3b 41       	pop	r11		
    4292:	30 41       	ret			

00004294 <Msp430TimerP__1__Event__fired>:
    4294:	7f 92       	cmp.b	#8,	r15	;r2 As==11
    4296:	5a 2c       	jc	$+182    	;abs 0x434c
    4298:	7f f3       	and.b	#-1,	r15	;r3 As==11
    429a:	0f 5f       	rla	r15		
    429c:	10 4f a0 42 	br	17056(r15)	;0x42a0(r15)
    42a0:	b0 42 e4 42 	mov	#8,	0x42e4	;r2 As==11, PC rel. 0x08588
    42a4:	f4 42 04 43 	mov.b	#8,	17156(r4);r2 As==11, 0x4304(r4)
    42a8:	14 43       	mov	#1,	r4	;r3 As==01
    42aa:	24 43       	mov	#2,	r4	;r3 As==10
    42ac:	34 43       	mov	#-1,	r4	;r3 As==11
    42ae:	44 43       	clr.b	r4		
    42b0:	1f 42 82 01 	mov	&0x0182,r15	
    42b4:	8f 10       	swpb	r15		
    42b6:	5f f3       	and.b	#1,	r15	;r3 As==01
    42b8:	03 24       	jz	$+8      	;abs 0x42c0
    42ba:	1f 42 92 01 	mov	&0x0192,r15	
    42be:	30 41       	ret			
    42c0:	b2 f0 ef ff 	and	#-17,	&0x0182	;#0xffef
    42c4:	82 01 
    42c6:	0e 43       	clr	r14		
    42c8:	0f 43       	clr	r15		
    42ca:	82 9e 08 11 	cmp	r14,	&0x1108	
    42ce:	07 20       	jnz	$+16     	;abs 0x42de
    42d0:	82 9f 0a 11 	cmp	r15,	&0x110a	
    42d4:	04 20       	jnz	$+10     	;abs 0x42de
    42d6:	4f 43       	clr.b	r15		
    42d8:	b0 12 bc 40 	call	#0x40bc	
    42dc:	30 41       	ret			
    42de:	b0 12 84 41 	call	#0x4184	
    42e2:	30 41       	ret			
    42e4:	1f 42 84 01 	mov	&0x0184,r15	
    42e8:	8f 10       	swpb	r15		
    42ea:	5f f3       	and.b	#1,	r15	;r3 As==01
    42ec:	2f 24       	jz	$+96     	;abs 0x434c
    42ee:	1f 42 94 01 	mov	&0x0194,r15	
    42f2:	30 41       	ret			
    42f4:	1f 42 86 01 	mov	&0x0186,r15	
    42f8:	8f 10       	swpb	r15		
    42fa:	5f f3       	and.b	#1,	r15	;r3 As==01
    42fc:	27 24       	jz	$+80     	;abs 0x434c
    42fe:	1f 42 96 01 	mov	&0x0196,r15	
    4302:	30 41       	ret			
    4304:	1f 42 88 01 	mov	&0x0188,r15	
    4308:	8f 10       	swpb	r15		
    430a:	5f f3       	and.b	#1,	r15	;r3 As==01
    430c:	1f 24       	jz	$+64     	;abs 0x434c
    430e:	1f 42 98 01 	mov	&0x0198,r15	
    4312:	30 41       	ret			
    4314:	1f 42 8a 01 	mov	&0x018a,r15	
    4318:	8f 10       	swpb	r15		
    431a:	5f f3       	and.b	#1,	r15	;r3 As==01
    431c:	17 24       	jz	$+48     	;abs 0x434c
    431e:	1f 42 9a 01 	mov	&0x019a,r15	
    4322:	30 41       	ret			
    4324:	1f 42 8c 01 	mov	&0x018c,r15	
    4328:	8f 10       	swpb	r15		
    432a:	5f f3       	and.b	#1,	r15	;r3 As==01
    432c:	0f 24       	jz	$+32     	;abs 0x434c
    432e:	1f 42 9c 01 	mov	&0x019c,r15	
    4332:	30 41       	ret			
    4334:	1f 42 8e 01 	mov	&0x018e,r15	
    4338:	8f 10       	swpb	r15		
    433a:	5f f3       	and.b	#1,	r15	;r3 As==01
    433c:	07 24       	jz	$+16     	;abs 0x434c
    433e:	1f 42 9e 01 	mov	&0x019e,r15	
    4342:	30 41       	ret			
    4344:	92 53 10 11 	inc	&0x1110	
    4348:	82 63 12 11 	adc	&0x1112	
    434c:	30 41       	ret			

0000434e <sig_TIMERB0_VECTOR>:
    434e:	0f 12       	push	r15		
    4350:	0e 12       	push	r14		
    4352:	0d 12       	push	r13		
    4354:	0c 12       	push	r12		
    4356:	4f 43       	clr.b	r15		
    4358:	b0 12 94 42 	call	#0x4294	
    435c:	3c 41       	pop	r12		
    435e:	3d 41       	pop	r13		
    4360:	3e 41       	pop	r14		
    4362:	3f 41       	pop	r15		
    4364:	b1 c0 f0 00 	bic	#240,	0(r1)	;#0x00f0, 0x0000(r1)
    4368:	00 00 
    436a:	00 13       	reti			

0000436c <sig_TIMERB1_VECTOR>:
    436c:	0f 12       	push	r15		
    436e:	0e 12       	push	r14		
    4370:	0d 12       	push	r13		
    4372:	0c 12       	push	r12		
    4374:	1f 42 1e 01 	mov	&0x011e,r15	
    4378:	12 c3       	clrc			
    437a:	4f 10       	rrc.b	r15		
    437c:	b0 12 94 42 	call	#0x4294	
    4380:	3c 41       	pop	r12		
    4382:	3d 41       	pop	r13		
    4384:	3e 41       	pop	r14		
    4386:	3f 41       	pop	r15		
    4388:	b1 c0 f0 00 	bic	#240,	0(r1)	;#0x00f0, 0x0000(r1)
    438c:	00 00 
    438e:	00 13       	reti			

00004390 <Msp430ClockP__set_dco_calib>:
    4390:	0d 4f       	mov	r15,	r13	
    4392:	8d 10       	swpb	r13		
    4394:	7d f0 07 00 	and.b	#7,	r13	;#0x0007
    4398:	5e 42 57 00 	mov.b	&0x0057,r14	
    439c:	7e f0 f8 ff 	and.b	#-8,	r14	;#0xfff8
    43a0:	4d de       	bis.b	r14,	r13	
    43a2:	c2 4d 57 00 	mov.b	r13,	&0x0057	
    43a6:	c2 4f 56 00 	mov.b	r15,	&0x0056	
    43aa:	30 41       	ret			

000043ac <MotePlatformC__TOSH_FLASH_M25P_DP_bit>:
    43ac:	4f 93       	tst.b	r15		
    43ae:	03 24       	jz	$+8      	;abs 0x43b6
    43b0:	e2 d3 19 00 	bis.b	#2,	&0x0019	;r3 As==10
    43b4:	02 3c       	jmp	$+6      	;abs 0x43ba
    43b6:	e2 c3 19 00 	bic.b	#2,	&0x0019	;r3 As==10
    43ba:	f2 d2 19 00 	bis.b	#8,	&0x0019	;r2 As==11
    43be:	f2 c2 19 00 	bic.b	#8,	&0x0019	;r2 As==11
    43c2:	30 41       	ret			

000043c4 <VirtualizeTimerC__0__fireTimers>:
    43c4:	0b 12       	push	r11		
    43c6:	0a 12       	push	r10		
    43c8:	09 12       	push	r9		
    43ca:	08 12       	push	r8		
    43cc:	07 12       	push	r7		
    43ce:	06 12       	push	r6		
    43d0:	05 12       	push	r5		
    43d2:	04 12       	push	r4		
    43d4:	0a 4e       	mov	r14,	r10	
    43d6:	0b 4f       	mov	r15,	r11	
    43d8:	3f 40 14 11 	mov	#4372,	r15	;#0x1114
    43dc:	4c 43       	clr.b	r12		
    43de:	04 4f       	mov	r15,	r4	
    43e0:	55 4f 08 00 	mov.b	8(r15),	r5	;0x0008(r15)
    43e4:	4e 45       	mov.b	r5,	r14	
    43e6:	6e f3       	and.b	#2,	r14	;r3 As==10
    43e8:	3a 24       	jz	$+118    	;abs 0x445e
    43ea:	38 4f       	mov	@r15+,	r8	
    43ec:	39 4f       	mov	@r15+,	r9	
    43ee:	2f 82       	sub	#4,	r15	;r2 As==10
    43f0:	16 4f 04 00 	mov	4(r15),	r6	;0x0004(r15)
    43f4:	17 4f 06 00 	mov	6(r15),	r7	;0x0006(r15)
    43f8:	0d 4a       	mov	r10,	r13	
    43fa:	0e 4b       	mov	r11,	r14	
    43fc:	0d 88       	sub	r8,	r13	
    43fe:	0e 79       	subc	r9,	r14	
    4400:	0d 86       	sub	r6,	r13	
    4402:	0e 77       	subc	r7,	r14	
    4404:	2c 28       	jnc	$+90     	;abs 0x445e
    4406:	55 f3       	and.b	#1,	r5	;r3 As==01
    4408:	03 24       	jz	$+8      	;abs 0x4410
    440a:	ef c3 08 00 	bic.b	#2,	8(r15)	;r3 As==10, 0x0008(r15)
    440e:	08 3c       	jmp	$+18     	;abs 0x4420
    4410:	0e 46       	mov	r6,	r14	
    4412:	0f 47       	mov	r7,	r15	
    4414:	0e 58       	add	r8,	r14	
    4416:	0f 69       	addc	r9,	r15	
    4418:	84 4e 00 00 	mov	r14,	0(r4)	;0x0000(r4)
    441c:	84 4f 02 00 	mov	r15,	2(r4)	;0x0002(r4)
    4420:	5c 93       	cmp.b	#1,	r12	;r3 As==01
    4422:	0d 24       	jz	$+28     	;abs 0x443e
    4424:	4c 93       	tst.b	r12		
    4426:	03 24       	jz	$+8      	;abs 0x442e
    4428:	6c 93       	cmp.b	#2,	r12	;r3 As==10
    442a:	1f 20       	jnz	$+64     	;abs 0x446a
    442c:	10 3c       	jmp	$+34     	;abs 0x444e
    442e:	b0 12 34 40 	call	#0x4034	
    4432:	f2 e0 10 00 	xor.b	#16,	&0x0031	;#0x0010
    4436:	31 00 
    4438:	b0 12 46 40 	call	#0x4046	
    443c:	16 3c       	jmp	$+46     	;abs 0x446a
    443e:	b0 12 34 40 	call	#0x4034	
    4442:	f2 e0 20 00 	xor.b	#32,	&0x0031	;#0x0020
    4446:	31 00 
    4448:	b0 12 46 40 	call	#0x4046	
    444c:	0e 3c       	jmp	$+30     	;abs 0x446a
    444e:	b0 12 34 40 	call	#0x4034	
    4452:	f2 e0 40 00 	xor.b	#64,	&0x0031	;#0x0040
    4456:	31 00 
    4458:	b0 12 46 40 	call	#0x4046	
    445c:	06 3c       	jmp	$+14     	;abs 0x446a
    445e:	5c 53       	inc.b	r12		
    4460:	3f 50 0a 00 	add	#10,	r15	;#0x000a
    4464:	7c 90 03 00 	cmp.b	#3,	r12	;#0x0003
    4468:	ba 23       	jnz	$-138    	;abs 0x43de
    446a:	5f 43       	mov.b	#1,	r15	;r3 As==01
    446c:	b0 12 bc 40 	call	#0x40bc	
    4470:	34 41       	pop	r4		
    4472:	35 41       	pop	r5		
    4474:	36 41       	pop	r6		
    4476:	37 41       	pop	r7		
    4478:	38 41       	pop	r8		
    447a:	39 41       	pop	r9		
    447c:	3a 41       	pop	r10		
    447e:	3b 41       	pop	r11		
    4480:	30 41       	ret			

00004482 <TransformAlarmC__0__Alarm__startAt>:
    4482:	0b 12       	push	r11		
    4484:	0a 12       	push	r10		
    4486:	09 12       	push	r9		
    4488:	08 12       	push	r8		
    448a:	07 12       	push	r7		
    448c:	08 4e       	mov	r14,	r8	
    448e:	09 4f       	mov	r15,	r9	
    4490:	0a 4c       	mov	r12,	r10	
    4492:	0b 4d       	mov	r13,	r11	
    4494:	b0 12 34 40 	call	#0x4034	
    4498:	47 4f       	mov.b	r15,	r7	
    449a:	82 48 0c 11 	mov	r8,	&0x110c	
    449e:	82 49 0e 11 	mov	r9,	&0x110e	
    44a2:	82 4a 08 11 	mov	r10,	&0x1108	
    44a6:	82 4b 0a 11 	mov	r11,	&0x110a	
    44aa:	b0 12 84 41 	call	#0x4184	
    44ae:	4f 47       	mov.b	r7,	r15	
    44b0:	b0 12 46 40 	call	#0x4046	
    44b4:	37 41       	pop	r7		
    44b6:	38 41       	pop	r8		
    44b8:	39 41       	pop	r9		
    44ba:	3a 41       	pop	r10		
    44bc:	3b 41       	pop	r11		
    44be:	30 41       	ret			

000044c0 <VirtualizeTimerC__0__updateFromTimer__runTask>:
    44c0:	0b 12       	push	r11		
    44c2:	0a 12       	push	r10		
    44c4:	09 12       	push	r9		
    44c6:	08 12       	push	r8		
    44c8:	07 12       	push	r7		
    44ca:	06 12       	push	r6		
    44cc:	05 12       	push	r5		
    44ce:	04 12       	push	r4		
    44d0:	b0 12 16 41 	call	#0x4116	
    44d4:	09 4e       	mov	r14,	r9	
    44d6:	0a 4f       	mov	r15,	r10	
    44d8:	b2 f0 ef ff 	and	#-17,	&0x0182	;#0xffef
    44dc:	82 01 
    44de:	3f 40 14 11 	mov	#4372,	r15	;#0x1114
    44e2:	05 4f       	mov	r15,	r5	
    44e4:	35 50 1e 00 	add	#30,	r5	;#0x001e
    44e8:	44 43       	clr.b	r4		
    44ea:	37 43       	mov	#-1,	r7	;r3 As==11
    44ec:	38 40 ff 7f 	mov	#32767,	r8	;#0x7fff
    44f0:	46 44       	mov.b	r4,	r6	
    44f2:	0d 4f       	mov	r15,	r13	
    44f4:	5f 4d 08 00 	mov.b	8(r13),	r15	;0x0008(r13)
    44f8:	6f f3       	and.b	#2,	r15	;r3 As==10
    44fa:	4f 96       	cmp.b	r6,	r15	
    44fc:	13 24       	jz	$+40     	;abs 0x4524
    44fe:	0e 49       	mov	r9,	r14	
    4500:	0f 4a       	mov	r10,	r15	
    4502:	3e 8d       	sub	@r13+,	r14	
    4504:	3f 7d       	subc	@r13+,	r15	
    4506:	2d 82       	sub	#4,	r13	;r2 As==10
    4508:	1b 4d 04 00 	mov	4(r13),	r11	;0x0004(r13)
    450c:	1c 4d 06 00 	mov	6(r13),	r12	;0x0006(r13)
    4510:	0b 8e       	sub	r14,	r11	
    4512:	0c 7f       	subc	r15,	r12	
    4514:	0e 4b       	mov	r11,	r14	
    4516:	0f 4c       	mov	r12,	r15	
    4518:	0b 87       	sub	r7,	r11	
    451a:	0c 78       	subc	r8,	r12	
    451c:	03 34       	jge	$+8      	;abs 0x4524
    451e:	07 4e       	mov	r14,	r7	
    4520:	08 4f       	mov	r15,	r8	
    4522:	54 43       	mov.b	#1,	r4	;r3 As==01
    4524:	3d 50 0a 00 	add	#10,	r13	;#0x000a
    4528:	0d 95       	cmp	r5,	r13	
    452a:	e4 23       	jnz	$-54     	;abs 0x44f4
    452c:	44 93       	tst.b	r4		
    452e:	16 24       	jz	$+46     	;abs 0x455c
    4530:	0e 43       	clr	r14		
    4532:	0f 43       	clr	r15		
    4534:	0e 87       	sub	r7,	r14	
    4536:	0f 78       	subc	r8,	r15	
    4538:	05 38       	jl	$+12     	;abs 0x4544
    453a:	0e 49       	mov	r9,	r14	
    453c:	0f 4a       	mov	r10,	r15	
    453e:	b0 12 c4 43 	call	#0x43c4	
    4542:	0c 3c       	jmp	$+26     	;abs 0x455c
    4544:	82 47 32 11 	mov	r7,	&0x1132	
    4548:	82 48 34 11 	mov	r8,	&0x1134	
    454c:	d2 43 06 11 	mov.b	#1,	&0x1106	;r3 As==01
    4550:	0c 47       	mov	r7,	r12	
    4552:	0d 48       	mov	r8,	r13	
    4554:	0e 49       	mov	r9,	r14	
    4556:	0f 4a       	mov	r10,	r15	
    4558:	b0 12 82 44 	call	#0x4482	
    455c:	34 41       	pop	r4		
    455e:	35 41       	pop	r5		
    4560:	36 41       	pop	r6		
    4562:	37 41       	pop	r7		
    4564:	38 41       	pop	r8		
    4566:	39 41       	pop	r9		
    4568:	3a 41       	pop	r10		
    456a:	3b 41       	pop	r11		
    456c:	30 41       	ret			

0000456e <AlarmToTimerC__0__fired__runTask>:
    456e:	0b 12       	push	r11		
    4570:	0a 12       	push	r10		
    4572:	09 12       	push	r9		
    4574:	08 12       	push	r8		
    4576:	c2 93 06 11 	tst.b	&0x1106	
    457a:	1c 20       	jnz	$+58     	;abs 0x45b4
    457c:	1a 42 32 11 	mov	&0x1132,r10	
    4580:	1b 42 34 11 	mov	&0x1134,r11	
    4584:	b0 12 34 40 	call	#0x4034	
    4588:	18 42 08 11 	mov	&0x1108,r8	
    458c:	19 42 0a 11 	mov	&0x110a,r9	
    4590:	18 52 0c 11 	add	&0x110c,r8	
    4594:	19 62 0e 11 	addc	&0x110e,r9	
    4598:	b0 12 46 40 	call	#0x4046	
    459c:	82 4a 32 11 	mov	r10,	&0x1132	
    45a0:	82 4b 34 11 	mov	r11,	&0x1134	
    45a4:	c2 43 06 11 	mov.b	#0,	&0x1106	;r3 As==00
    45a8:	0c 4a       	mov	r10,	r12	
    45aa:	0d 4b       	mov	r11,	r13	
    45ac:	0e 48       	mov	r8,	r14	
    45ae:	0f 49       	mov	r9,	r15	
    45b0:	b0 12 82 44 	call	#0x4482	
    45b4:	b0 12 16 41 	call	#0x4116	
    45b8:	b0 12 c4 43 	call	#0x43c4	
    45bc:	38 41       	pop	r8		
    45be:	39 41       	pop	r9		
    45c0:	3a 41       	pop	r10		
    45c2:	3b 41       	pop	r11		
    45c4:	30 41       	ret			

000045c6 <SchedulerBasicP__Scheduler__runNextTask>:
    45c6:	5f 42 36 11 	mov.b	&0x1136,r15	
    45ca:	7f 93       	cmp.b	#-1,	r15	;r3 As==11
    45cc:	02 20       	jnz	$+6      	;abs 0x45d2
    45ce:	4f 43       	clr.b	r15		
    45d0:	30 41       	ret			
    45d2:	4d 4f       	mov.b	r15,	r13	
    45d4:	0e 4d       	mov	r13,	r14	
    45d6:	3e 50 04 11 	add	#4356,	r14	;#0x1104
    45da:	6c 4e       	mov.b	@r14,	r12	
    45dc:	c2 4c 36 11 	mov.b	r12,	&0x1136	
    45e0:	7c 93       	cmp.b	#-1,	r12	;r3 As==11
    45e2:	02 20       	jnz	$+6      	;abs 0x45e8
    45e4:	f2 43 37 11 	mov.b	#-1,	&0x1137	;r3 As==11
    45e8:	fd 43 04 11 	mov.b	#-1,	4356(r13);r3 As==11, 0x1104(r13)
    45ec:	4f 93       	tst.b	r15		
    45ee:	04 24       	jz	$+10     	;abs 0x45f8
    45f0:	5f 93       	cmp.b	#1,	r15	;r3 As==01
    45f2:	06 24       	jz	$+14     	;abs 0x4600
    45f4:	5f 43       	mov.b	#1,	r15	;r3 As==01
    45f6:	30 41       	ret			
    45f8:	b0 12 6e 45 	call	#0x456e	
    45fc:	5f 43       	mov.b	#1,	r15	;r3 As==01
    45fe:	30 41       	ret			
    4600:	b0 12 c0 44 	call	#0x44c0	
    4604:	5f 43       	mov.b	#1,	r15	;r3 As==01
    4606:	30 41       	ret			

00004608 <VirtualizeTimerC__0__Timer__startPeriodic>:
    4608:	0b 12       	push	r11		
    460a:	0a 12       	push	r10		
    460c:	09 12       	push	r9		
    460e:	4b 4f       	mov.b	r15,	r11	
    4610:	09 4d       	mov	r13,	r9	
    4612:	0a 4e       	mov	r14,	r10	
    4614:	b0 12 16 41 	call	#0x4116	
    4618:	4c 4b       	mov.b	r11,	r12	
    461a:	0c 5c       	rla	r12		
    461c:	0c 5c       	rla	r12		
    461e:	7b f3       	and.b	#-1,	r11	;r3 As==11
    4620:	0b 5b       	rla	r11		
    4622:	0c 5b       	add	r11,	r12	
    4624:	0c 5b       	add	r11,	r12	
    4626:	0c 5b       	add	r11,	r12	
    4628:	3c 50 14 11 	add	#4372,	r12	;#0x1114
    462c:	8c 4e 00 00 	mov	r14,	0(r12)	;0x0000(r12)
    4630:	8c 4f 02 00 	mov	r15,	2(r12)	;0x0002(r12)
    4634:	8c 49 04 00 	mov	r9,	4(r12)	;0x0004(r12)
    4638:	8c 4a 06 00 	mov	r10,	6(r12)	;0x0006(r12)
    463c:	5f 4c 08 00 	mov.b	8(r12),	r15	;0x0008(r12)
    4640:	5f c3       	bic.b	#1,	r15	;r3 As==01
    4642:	6f d3       	bis.b	#2,	r15	;r3 As==10
    4644:	cc 4f 08 00 	mov.b	r15,	8(r12)	;0x0008(r12)
    4648:	5f 43       	mov.b	#1,	r15	;r3 As==01
    464a:	b0 12 bc 40 	call	#0x40bc	
    464e:	39 41       	pop	r9		
    4650:	3a 41       	pop	r10		
    4652:	3b 41       	pop	r11		
    4654:	30 41       	ret			

00004656 <main>:
    4656:	31 40 fe 38 	mov	#14590,	r1	;#0x38fe
    465a:	b0 12 34 40 	call	#0x4034	
    465e:	46 4f       	mov.b	r15,	r6	
    4660:	3e 40 04 11 	mov	#4356,	r14	;#0x1104
    4664:	fe 43 00 00 	mov.b	#-1,	0(r14)	;r3 As==11, 0x0000(r14)
    4668:	fe 43 01 00 	mov.b	#-1,	1(r14)	;r3 As==11, 0x0001(r14)
    466c:	f2 43 36 11 	mov.b	#-1,	&0x1136	;r3 As==11
    4670:	f2 43 37 11 	mov.b	#-1,	&0x1137	;r3 As==11
    4674:	a2 42 60 01 	mov	#4,	&0x0160	;r2 As==10
    4678:	82 43 2e 01 	mov	#0,	&0x012e	;r3 As==00
    467c:	a2 42 80 01 	mov	#4,	&0x0180	;r2 As==10
    4680:	82 43 1e 01 	mov	#0,	&0x011e	;r3 As==00
    4684:	b2 40 20 02 	mov	#544,	&0x0160	;#0x0220
    4688:	60 01 
    468a:	b2 40 20 01 	mov	#288,	&0x0180	;#0x0120
    468e:	80 01 
    4690:	f2 40 84 ff 	mov.b	#-124,	&0x0057	;#0xff84
    4694:	57 00 
    4696:	c2 43 58 00 	mov.b	#0,	&0x0058	;r3 As==00
    469a:	b2 40 00 40 	mov	#16384,	&0x0182	;#0x4000
    469e:	82 01 
    46a0:	0a 43       	clr	r10		
    46a2:	38 40 00 08 	mov	#2048,	r8	;#0x0800
    46a6:	09 4a       	mov	r10,	r9	
    46a8:	07 4a       	mov	r10,	r7	
    46aa:	55 43       	mov.b	#1,	r5	;r3 As==01
    46ac:	34 40 0c 00 	mov	#12,	r4	;#0x000c
    46b0:	0b 48       	mov	r8,	r11	
    46b2:	0b d9       	bis	r9,	r11	
    46b4:	0f 4b       	mov	r11,	r15	
    46b6:	b0 12 90 43 	call	#0x4390	
    46ba:	0c 47       	mov	r7,	r12	
    46bc:	4f 45       	mov.b	r5,	r15	
    46be:	1e 42 90 01 	mov	&0x0190,r14	
    46c2:	3e 52       	add	#8,	r14	;r2 As==11
    46c4:	82 4e 92 01 	mov	r14,	&0x0192	
    46c8:	92 c3 82 01 	bic	#1,	&0x0182	;r3 As==01
    46cc:	1e 42 82 01 	mov	&0x0182,r14	
    46d0:	1e f3       	and	#1,	r14	;r3 As==01
    46d2:	0e 97       	cmp	r7,	r14	
    46d4:	fb 27       	jz	$-8      	;abs 0x46cc
    46d6:	1e 42 70 01 	mov	&0x0170,r14	
    46da:	4f 93       	tst.b	r15		
    46dc:	03 24       	jz	$+8      	;abs 0x46e4
    46de:	7f 53       	add.b	#-1,	r15	;r3 As==11
    46e0:	0c 4e       	mov	r14,	r12	
    46e2:	ed 3f       	jmp	$-36     	;abs 0x46be
    46e4:	0e 8c       	sub	r12,	r14	
    46e6:	3f 40 00 04 	mov	#1024,	r15	;#0x0400
    46ea:	0f 9e       	cmp	r14,	r15	
    46ec:	01 2c       	jc	$+4      	;abs 0x46f0
    46ee:	0b 49       	mov	r9,	r11	
    46f0:	08 11       	rra	r8		
    46f2:	1a 53       	inc	r10		
    46f4:	0a 94       	cmp	r4,	r10	
    46f6:	02 24       	jz	$+6      	;abs 0x46fc
    46f8:	09 4b       	mov	r11,	r9	
    46fa:	da 3f       	jmp	$-74     	;abs 0x46b0
    46fc:	0d 4b       	mov	r11,	r13	
    46fe:	3d f0 e0 00 	and	#224,	r13	;#0x00e0
    4702:	3d 90 e0 00 	cmp	#224,	r13	;#0x00e0
    4706:	02 20       	jnz	$+6      	;abs 0x470c
    4708:	3b f0 e0 ff 	and	#-32,	r11	;#0xffe0
    470c:	0f 4b       	mov	r11,	r15	
    470e:	b0 12 90 43 	call	#0x4390	
    4712:	5e 42 57 00 	mov.b	&0x0057,r14	
    4716:	7e f0 07 00 	and.b	#7,	r14	;#0x0007
    471a:	7e d0 80 ff 	bis.b	#-128,	r14	;#0xff80
    471e:	c2 4e 57 00 	mov.b	r14,	&0x0057	
    4722:	e2 42 58 00 	mov.b	#4,	&0x0058	;r2 As==10
    4726:	e2 c3 00 00 	bic.b	#2,	&0x0000	;r3 As==10
    472a:	82 43 70 01 	mov	#0,	&0x0170	;r3 As==00
    472e:	b2 40 02 02 	mov	#514,	&0x0160	;#0x0202
    4732:	60 01 
    4734:	82 43 90 01 	mov	#0,	&0x0190	;r3 As==00
    4738:	b2 40 02 01 	mov	#258,	&0x0180	;#0x0102
    473c:	80 01 
    473e:	1e 42 60 01 	mov	&0x0160,r14	
    4742:	3e f0 cf ff 	and	#-49,	r14	;#0xffcf
    4746:	3e d0 20 00 	bis	#32,	r14	;#0x0020
    474a:	82 4e 60 01 	mov	r14,	&0x0160	
    474e:	1e 42 80 01 	mov	&0x0180,r14	
    4752:	3e f0 cf ff 	and	#-49,	r14	;#0xffcf
    4756:	3e d0 20 00 	bis	#32,	r14	;#0x0020
    475a:	82 4e 80 01 	mov	r14,	&0x0180	
    475e:	c2 43 26 00 	mov.b	#0,	&0x0026	;r3 As==00
    4762:	c2 43 2e 00 	mov.b	#0,	&0x002e	;r3 As==00
    4766:	c2 43 1b 00 	mov.b	#0,	&0x001b	;r3 As==00
    476a:	c2 43 1f 00 	mov.b	#0,	&0x001f	;r3 As==00
    476e:	c2 43 33 00 	mov.b	#0,	&0x0033	;r3 As==00
    4772:	c2 43 37 00 	mov.b	#0,	&0x0037	;r3 As==00
    4776:	c2 43 21 00 	mov.b	#0,	&0x0021	;r3 As==00
    477a:	f2 40 e0 ff 	mov.b	#-32,	&0x0022	;#0xffe0
    477e:	22 00 
    4780:	f2 40 30 00 	mov.b	#48,	&0x0029	;#0x0030
    4784:	29 00 
    4786:	f2 40 7b 00 	mov.b	#123,	&0x002a	;#0x007b
    478a:	2a 00 
    478c:	c2 43 19 00 	mov.b	#0,	&0x0019	;r3 As==00
    4790:	f2 40 f1 ff 	mov.b	#-15,	&0x001a	;#0xfff1
    4794:	1a 00 
    4796:	f2 40 dd ff 	mov.b	#-35,	&0x001d	;#0xffdd
    479a:	1d 00 
    479c:	f2 40 fd ff 	mov.b	#-3,	&0x001e	;#0xfffd
    47a0:	1e 00 
    47a2:	f2 43 31 00 	mov.b	#-1,	&0x0031	;r3 As==11
    47a6:	f2 43 32 00 	mov.b	#-1,	&0x0032	;r3 As==11
    47aa:	c2 43 35 00 	mov.b	#0,	&0x0035	;r3 As==00
    47ae:	f2 43 36 00 	mov.b	#-1,	&0x0036	;r3 As==11
    47b2:	c2 43 25 00 	mov.b	#0,	&0x0025	;r3 As==00
    47b6:	c2 43 2d 00 	mov.b	#0,	&0x002d	;r3 As==00
    47ba:	1e 42 70 01 	mov	&0x0170,r14	
    47be:	3d 40 00 28 	mov	#10240,	r13	;#0x2800
    47c2:	1f 42 70 01 	mov	&0x0170,r15	
    47c6:	0f 8e       	sub	r14,	r15	
    47c8:	0d 9f       	cmp	r15,	r13	
    47ca:	fb 2f       	jc	$-8      	;abs 0x47c2
    47cc:	e2 d3 1a 00 	bis.b	#2,	&0x001a	;r3 As==10
    47d0:	f2 d2 1a 00 	bis.b	#8,	&0x001a	;r2 As==11
    47d4:	f2 d0 80 ff 	bis.b	#-128,	&0x001e	;#0xff80
    47d8:	1e 00 
    47da:	f2 d0 10 00 	bis.b	#16,	&0x001e	;#0x0010
    47de:	1e 00 
    47e0:	f2 d0 80 ff 	bis.b	#-128,	&0x001d	;#0xff80
    47e4:	1d 00 
    47e6:	f2 d0 10 00 	bis.b	#16,	&0x001d	;#0x0010
    47ea:	1d 00 
    47ec:	03 43       	nop			
    47ee:	03 43       	nop			
    47f0:	f2 f0 ef ff 	and.b	#-17,	&0x001d	;#0xffef
    47f4:	1d 00 
    47f6:	f2 c2 19 00 	bic.b	#8,	&0x0019	;r2 As==11
    47fa:	5b 43       	mov.b	#1,	r11	;r3 As==01
    47fc:	4f 4b       	mov.b	r11,	r15	
    47fe:	b0 12 ac 43 	call	#0x43ac	
    4802:	4f 43       	clr.b	r15		
    4804:	b0 12 ac 43 	call	#0x43ac	
    4808:	4f 4b       	mov.b	r11,	r15	
    480a:	b0 12 ac 43 	call	#0x43ac	
    480e:	4f 4b       	mov.b	r11,	r15	
    4810:	b0 12 ac 43 	call	#0x43ac	
    4814:	4f 4b       	mov.b	r11,	r15	
    4816:	b0 12 ac 43 	call	#0x43ac	
    481a:	4f 43       	clr.b	r15		
    481c:	b0 12 ac 43 	call	#0x43ac	
    4820:	4f 43       	clr.b	r15		
    4822:	b0 12 ac 43 	call	#0x43ac	
    4826:	4f 4b       	mov.b	r11,	r15	
    4828:	b0 12 ac 43 	call	#0x43ac	
    482c:	f2 d0 10 00 	bis.b	#16,	&0x001d	;#0x0010
    4830:	1d 00 
    4832:	f2 d2 19 00 	bis.b	#8,	&0x0019	;r2 As==11
    4836:	e2 d3 19 00 	bis.b	#2,	&0x0019	;r3 As==10
    483a:	3e 40 32 00 	mov	#50,	r14	;#0x0032
    483e:	fe d0 10 00 	bis.b	#16,	0(r14)	;#0x0010, 0x0000(r14)
    4842:	00 00 
    4844:	fe d0 20 00 	bis.b	#32,	0(r14)	;#0x0020, 0x0000(r14)
    4848:	00 00 
    484a:	fe d0 40 00 	bis.b	#64,	0(r14)	;#0x0040, 0x0000(r14)
    484e:	00 00 
    4850:	3e 53       	add	#-1,	r14	;r3 As==11
    4852:	fe d0 10 00 	bis.b	#16,	0(r14)	;#0x0010, 0x0000(r14)
    4856:	00 00 
    4858:	fe d0 20 00 	bis.b	#32,	0(r14)	;#0x0020, 0x0000(r14)
    485c:	00 00 
    485e:	fe d0 40 00 	bis.b	#64,	0(r14)	;#0x0040, 0x0000(r14)
    4862:	00 00 
    4864:	4b 43       	clr.b	r11		
    4866:	b0 12 c6 45 	call	#0x45c6	
    486a:	4f 9b       	cmp.b	r11,	r15	
    486c:	fc 23       	jnz	$-6      	;abs 0x4866
    486e:	3e 40 82 01 	mov	#386,	r14	;#0x0182
    4872:	be f0 ef ff 	and	#-17,	0(r14)	;#0xffef, 0x0000(r14)
    4876:	00 00 
    4878:	be 40 00 40 	mov	#16384,	0(r14)	;#0x4000, 0x0000(r14)
    487c:	00 00 
    487e:	4b 43       	clr.b	r11		
    4880:	b0 12 c6 45 	call	#0x45c6	
    4884:	4f 9b       	cmp.b	r11,	r15	
    4886:	fc 23       	jnz	$-6      	;abs 0x4880
    4888:	4f 46       	mov.b	r6,	r15	
    488a:	b0 12 46 40 	call	#0x4046	
    488e:	32 d2       	eint			
    4890:	3d 40 fa 00 	mov	#250,	r13	;#0x00fa
    4894:	0e 43       	clr	r14		
    4896:	4f 43       	clr.b	r15		
    4898:	b0 12 08 46 	call	#0x4608	
    489c:	3d 40 f4 01 	mov	#500,	r13	;#0x01f4
    48a0:	0e 43       	clr	r14		
    48a2:	5f 43       	mov.b	#1,	r15	;r3 As==01
    48a4:	b0 12 08 46 	call	#0x4608	
    48a8:	3d 40 e8 03 	mov	#1000,	r13	;#0x03e8
    48ac:	0e 43       	clr	r14		
    48ae:	6f 43       	mov.b	#2,	r15	;r3 As==10
    48b0:	b0 12 08 46 	call	#0x4608	
    48b4:	79 43       	mov.b	#-1,	r9	;r3 As==11
    48b6:	48 43       	clr.b	r8		
    48b8:	0a 43       	clr	r10		
    48ba:	67 42       	mov.b	#4,	r7	;r2 As==10
    48bc:	66 43       	mov.b	#2,	r6	;r3 As==10
    48be:	34 40 00 02 	mov	#512,	r4	;#0x0200
    48c2:	55 43       	mov.b	#1,	r5	;r3 As==01
    48c4:	b0 12 34 40 	call	#0x4034	
    48c8:	80 3c       	jmp	$+258    	;abs 0x49ca
    48ca:	1e 42 62 01 	mov	&0x0162,r14	
    48ce:	3e f0 10 00 	and	#16,	r14	;#0x0010
    48d2:	0e 9a       	cmp	r10,	r14	
    48d4:	0c 20       	jnz	$+26     	;abs 0x48ee
    48d6:	1e 42 64 01 	mov	&0x0164,r14	
    48da:	3e f0 10 00 	and	#16,	r14	;#0x0010
    48de:	0e 9a       	cmp	r10,	r14	
    48e0:	06 20       	jnz	$+14     	;abs 0x48ee
    48e2:	1e 42 66 01 	mov	&0x0166,r14	
    48e6:	3e f0 10 00 	and	#16,	r14	;#0x0010
    48ea:	0e 9a       	cmp	r10,	r14	
    48ec:	06 24       	jz	$+14     	;abs 0x48fa
    48ee:	1e 42 60 01 	mov	&0x0160,r14	
    48f2:	3e f0 00 03 	and	#768,	r14	;#0x0300
    48f6:	0e 94       	cmp	r4,	r14	
    48f8:	37 24       	jz	$+112    	;abs 0x4968
    48fa:	5e 42 04 00 	mov.b	&0x0004,r14	
    48fe:	7e f0 c0 ff 	and.b	#-64,	r14	;#0xffc0
    4902:	4e 98       	cmp.b	r8,	r14	
    4904:	06 24       	jz	$+14     	;abs 0x4912
    4906:	5e 42 71 00 	mov.b	&0x0071,r14	
    490a:	3e f0 20 00 	and	#32,	r14	;#0x0020
    490e:	0e 9a       	cmp	r10,	r14	
    4910:	2b 20       	jnz	$+88     	;abs 0x4968
    4912:	5e 42 05 00 	mov.b	&0x0005,r14	
    4916:	3e f0 30 00 	and	#48,	r14	;#0x0030
    491a:	0e 9a       	cmp	r10,	r14	
    491c:	06 24       	jz	$+14     	;abs 0x492a
    491e:	5e 42 79 00 	mov.b	&0x0079,r14	
    4922:	3e f0 20 00 	and	#32,	r14	;#0x0020
    4926:	0e 9a       	cmp	r10,	r14	
    4928:	1f 20       	jnz	$+64     	;abs 0x4968
    492a:	5e 42 70 00 	mov.b	&0x0070,r14	
    492e:	1e f3       	and	#1,	r14	;r3 As==01
    4930:	0e 9a       	cmp	r10,	r14	
    4932:	17 24       	jz	$+48     	;abs 0x4962
    4934:	5e 42 71 00 	mov.b	&0x0071,r14	
    4938:	3e f0 20 00 	and	#32,	r14	;#0x0020
    493c:	0e 9a       	cmp	r10,	r14	
    493e:	11 24       	jz	$+36     	;abs 0x4962
    4940:	5e 42 72 00 	mov.b	&0x0072,r14	
    4944:	3e f0 20 00 	and	#32,	r14	;#0x0020
    4948:	0e 9a       	cmp	r10,	r14	
    494a:	0b 24       	jz	$+24     	;abs 0x4962
    494c:	5e 42 70 00 	mov.b	&0x0070,r14	
    4950:	2e f2       	and	#4,	r14	;r2 As==10
    4952:	0e 9a       	cmp	r10,	r14	
    4954:	06 24       	jz	$+14     	;abs 0x4962
    4956:	5e 42 70 00 	mov.b	&0x0070,r14	
    495a:	3e f0 20 00 	and	#32,	r14	;#0x0020
    495e:	0e 9a       	cmp	r10,	r14	
    4960:	03 20       	jnz	$+8      	;abs 0x4968
    4962:	7e 40 05 00 	mov.b	#5,	r14	;#0x0005
    4966:	01 3c       	jmp	$+4      	;abs 0x496a
    4968:	4e 46       	mov.b	r6,	r14	
    496a:	1d 42 a0 01 	mov	&0x01a0,r13	
    496e:	3d f0 10 00 	and	#16,	r13	;#0x0010
    4972:	0d 9a       	cmp	r10,	r13	
    4974:	1a 24       	jz	$+54     	;abs 0x49aa
    4976:	1d 42 a2 01 	mov	&0x01a2,r13	
    497a:	3d f0 10 00 	and	#16,	r13	;#0x0010
    497e:	0d 9a       	cmp	r10,	r13	
    4980:	07 24       	jz	$+16     	;abs 0x4990
    4982:	1e 42 a2 01 	mov	&0x01a2,r14	
    4986:	3e f2       	and	#8,	r14	;r2 As==11
    4988:	0e 9a       	cmp	r10,	r14	
    498a:	0e 20       	jnz	$+30     	;abs 0x49a8
    498c:	4e 48       	mov.b	r8,	r14	
    498e:	0d 3c       	jmp	$+28     	;abs 0x49aa
    4990:	1d 42 a2 01 	mov	&0x01a2,r13	
    4994:	3d f0 00 04 	and	#1024,	r13	;#0x0400
    4998:	0d 9a       	cmp	r10,	r13	
    499a:	07 24       	jz	$+16     	;abs 0x49aa
    499c:	1d 42 60 01 	mov	&0x0160,r13	
    49a0:	3d f0 00 03 	and	#768,	r13	;#0x0300
    49a4:	0d 94       	cmp	r4,	r13	
    49a6:	01 20       	jnz	$+4      	;abs 0x49aa
    49a8:	4e 46       	mov.b	r6,	r14	
    49aa:	47 9e       	cmp.b	r14,	r7	
    49ac:	01 2c       	jc	$+4      	;abs 0x49b0
    49ae:	4e 47       	mov.b	r7,	r14	
    49b0:	c2 4e 02 11 	mov.b	r14,	&0x1102	
    49b4:	5e 42 02 11 	mov.b	&0x1102,r14	
    49b8:	0e 5e       	rla	r14		
    49ba:	1e 4e 2a 4a 	mov	18986(r14),r14	;0x4a2a(r14)
    49be:	3e d2       	bis	#8,	r14	;r2 As==11
    49c0:	81 4e 00 00 	mov	r14,	0(r1)	;0x0000(r1)
    49c4:	22 d1       	bis	@r1,	r2	
    49c6:	32 c2       	dint			
    49c8:	03 43       	nop			
    49ca:	5b 42 36 11 	mov.b	&0x1136,r11	
    49ce:	4b 99       	cmp.b	r9,	r11	
    49d0:	14 24       	jz	$+42     	;abs 0x49fa
    49d2:	4d 4b       	mov.b	r11,	r13	
    49d4:	0e 4d       	mov	r13,	r14	
    49d6:	3e 50 04 11 	add	#4356,	r14	;#0x1104
    49da:	6c 4e       	mov.b	@r14,	r12	
    49dc:	c2 4c 36 11 	mov.b	r12,	&0x1136	
    49e0:	4c 99       	cmp.b	r9,	r12	
    49e2:	02 20       	jnz	$+6      	;abs 0x49e8
    49e4:	c2 49 37 11 	mov.b	r9,	&0x1137	
    49e8:	fd 43 04 11 	mov.b	#-1,	4356(r13);r3 As==11, 0x1104(r13)
    49ec:	b0 12 46 40 	call	#0x4046	
    49f0:	4b 98       	cmp.b	r8,	r11	
    49f2:	07 24       	jz	$+16     	;abs 0x4a02
    49f4:	4b 95       	cmp.b	r5,	r11	
    49f6:	66 23       	jnz	$-306    	;abs 0x48c4
    49f8:	07 3c       	jmp	$+16     	;abs 0x4a08
    49fa:	c2 98 00 11 	cmp.b	r8,	&0x1100	
    49fe:	65 23       	jnz	$-308    	;abs 0x48ca
    4a00:	d9 3f       	jmp	$-76     	;abs 0x49b4
    4a02:	b0 12 6e 45 	call	#0x456e	
    4a06:	5e 3f       	jmp	$-322    	;abs 0x48c4
    4a08:	b0 12 c0 44 	call	#0x44c0	
    4a0c:	5b 3f       	jmp	$-328    	;abs 0x48c4

00004a0e <sig_TIMERA0_VECTOR>:
    4a0e:	0f 12       	push	r15		
    4a10:	0e 12       	push	r14		
    4a12:	0d 12       	push	r13		
    4a14:	0c 12       	push	r12		
    4a16:	b0 12 4e 40 	call	#0x404e	
    4a1a:	3c 41       	pop	r12		
    4a1c:	3d 41       	pop	r13		
    4a1e:	3e 41       	pop	r14		
    4a20:	3f 41       	pop	r15		
    4a22:	b1 c0 f0 00 	bic	#240,	0(r1)	;#0x00f0, 0x0000(r1)
    4a26:	00 00 
    4a28:	00 13       	reti			

00004a2a <McuSleepC__msp430PowerBits>:
    4a2a:	00 00       	.word	0x0000;	????	
    4a2c:	10 00       	.word	0x0010;	????	
    4a2e:	50 00       	.word	0x0050;	????	
    4a30:	90 00       	.word	0x0090;	????	
    4a32:	d0 00       	.word	0x00d0;	????	
    4a34:	f0 00       	.word	0x00f0;	????	

00004a36 <_unexpected_>:
    4a36:	00 13       	reti			

Disassembly of section .data:

00001100 <McuSleepC__dirty>:
    1100:	01 00       	.word	0x0001;	????	

Disassembly of section .bss:

00001102 <McuSleepC__powerState>:
	...

00001104 <SchedulerBasicP__m_next>:
	...

00001106 <AlarmToTimerC__0__m_oneshot>:
	...

00001108 <TransformAlarmC__0__m_dt>:
    1108:	00 00       	.word	0x0000;	????	
	...

0000110c <TransformAlarmC__0__m_t0>:
    110c:	00 00       	.word	0x0000;	????	
	...

00001110 <TransformCounterC__0__m_upper>:
    1110:	00 00       	.word	0x0000;	????	
	...

00001114 <VirtualizeTimerC__0__m_timers>:
	...

00001132 <AlarmToTimerC__0__m_dt>:
    1132:	00 00       	.word	0x0000;	????	
	...

00001136 <SchedulerBasicP__m_head>:
	...

00001137 <SchedulerBasicP__m_tail>:
	...

Disassembly of section .vectors:

0000ffe0 <InterruptVectors>:
    ffe0:	30 40       	interrupt service routine at 0x4030
    ffe2:	30 40       	interrupt service routine at 0x4030
    ffe4:	30 40       	interrupt service routine at 0x4030
    ffe6:	30 40       	interrupt service routine at 0x4030
    ffe8:	30 40       	interrupt service routine at 0x4030
    ffea:	7e 40       	interrupt service routine at 0x407e
    ffec:	0e 4a       	interrupt service routine at 0x4a0e
    ffee:	30 40       	interrupt service routine at 0x4030
    fff0:	30 40       	interrupt service routine at 0x4030
    fff2:	30 40       	interrupt service routine at 0x4030
    fff4:	30 40       	interrupt service routine at 0x4030
    fff6:	30 40       	interrupt service routine at 0x4030
    fff8:	6c 43       	interrupt service routine at 0x436c
    fffa:	4e 43       	interrupt service routine at 0x434e
    fffc:	30 40       	interrupt service routine at 0x4030
    fffe:	00 40       	interrupt service routine at 0x4000
