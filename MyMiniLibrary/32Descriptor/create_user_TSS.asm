load_relocate_program:                      ;���ز��ض�λ�û�����
                                            ;����: PUSH �߼�������
                                            ;      PUSH ������ƿ����ַ
                                            ;������� 
         pushad
		 push		ds
		 push		es
		 

		 mov		eax, Ring0FlatData
		 mov		es, eax
		 
		 ;�����û������TSS
         mov ecx,104                        ;tss�Ļ����ߴ�
         mov [es:esi+0x12],cx              
         dec word [es:esi+0x12]             ;�Ǽ�TSS����ֵ��TCB 
         call sys_routine_seg_sel:allocate_memory
         mov [es:esi+0x14],ecx              ;�Ǽ�TSS����ַ��TCB
      
         ;�Ǽǻ�����TSS�������
         mov word [es:ecx+0],0              ;������=0
      
         mov edx,[es:esi+0x24]              ;�Ǽ�0��Ȩ����ջ��ʼESP
         mov [es:ecx+4],edx                 ;��TSS��
      
         mov dx,[es:esi+0x22]               ;�Ǽ�0��Ȩ����ջ��ѡ����
         mov [es:ecx+8],dx                  ;��TSS��
      
         mov edx,[es:esi+0x32]              ;�Ǽ�1��Ȩ����ջ��ʼESP
         mov [es:ecx+12],edx                ;��TSS��

         mov dx,[es:esi+0x30]               ;�Ǽ�1��Ȩ����ջ��ѡ����
         mov [es:ecx+16],dx                 ;��TSS��

         mov edx,[es:esi+0x40]              ;�Ǽ�2��Ȩ����ջ��ʼESP
         mov [es:ecx+20],edx                ;��TSS��

         mov dx,[es:esi+0x3e]               ;�Ǽ�2��Ȩ����ջ��ѡ����
         mov [es:ecx+24],dx                 ;��TSS��

         mov dx,[es:esi+0x10]               ;�Ǽ������LDTѡ����
         mov [es:ecx+96],dx                 ;��TSS��
      
         mov dx,[es:esi+0x12]               ;�Ǽ������I/Oλͼƫ��
         mov [es:ecx+102],dx                ;��TSS�� 
      
         mov word [es:ecx+100],0            ;T=0
       
         ;��GDT�еǼ�TSS������
         mov eax,[es:esi+0x14]              ;TSS����ʼ���Ե�ַ
         movzx ebx,word [es:esi+0x12]       ;�γ��ȣ����ޣ�
         mov ecx,0x00408900                 ;TSS����������Ȩ��0
         call sys_routine_seg_sel:make_seg_descriptor
		 
         pop es                             ;�ָ������ô˹���ǰ��es�� 
         pop ds                             ;�ָ������ô˹���ǰ��ds��
      
         popad
      
         ret 8                              ;�������ñ�����ǰѹ��Ĳ��� 