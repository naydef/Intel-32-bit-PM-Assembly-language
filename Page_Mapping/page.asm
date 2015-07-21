;    page.asm
;    System Page Map
;			0x0001_0000 ~ 0x0001_FFFF
;		    LBA:5,6           = 2 Sectors
;    By using Library codes to fill this file.
;
;   Finally Modified by: ;	Mighten Dai<mighten.dai@gmail.com>
;                             15:46, July 21, 2015

%include "common_macro.asm"

;  Page Directory:    0x0001_0000 ~ 0x0001_0FFF

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;	!!!!!!Caution !!!!
;   The following Memory space described in "ReadMe.MD" must remain fixed
;           while switching to Paging Mode ( CR0.PG = 1 )
;  
;  --> 0x0000_0000 ~ 0x0000_7FFF: MBR
;  --> 0x0001_0000 ~ 0x0001_FFFF: Page Map
;  --> 0x0003_0000 ~ 0x0003_FFFF: System Information
;  --> 0x0004_0000 ~ 0x0004_FFFF: System Stack
;  --> 0x000B_8000 ~ 0x000B_FFFF: Video Buffer
;
; Here is the Phy-Address 0x0001_0000
;
;  Page Directory:  point to Page Table Phy-Address 0x0001_1000
dd    0x0001_1007        ; Page Index # 000, Ranged from 0x0000_0000 to 0x003F_FFFF
;dd    0x0001_1007        ; Page Index # 001, Ranged from 0x0040_0000 to 0x004F_FFFF

times 0x400 - ( $ - $$ ) dd 0x0000_0000  ; 0x0000_0000 means Present is cleared(=0)




;0x0000_0244 Here: