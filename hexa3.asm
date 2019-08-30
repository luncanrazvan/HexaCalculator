.386
.model flat, stdcall

includelib msvcrt.lib
extern exit: proc
extern scanf:proc
extern printf:proc
extern strcmp:proc
extern fprintf:proc
extern fscanf:proc
extern fopen:proc
extern fclose:proc

public start

.data

sir1 db 500 dup(0),0
vector dd 500 dup(0),0
expresie db "Introduceti o expreise:",13,10,0

backslashn dd 10

fisier db "fisier.txt",0

mode1 db "w",0

mode2 db "r",0

formatx db "%X",0

formats db "%s",0

formatd db "%d",0

formatc db "%c",0

iesire db "exit",0


nr dd 0h
caracter dd 0
contor dd 0
pointer dd 0
suma dd 0h
de dd 0
im dd 0


.code

adunare PROC
	push ebp
	mov ebp,esp
	
	mov eax,ecx
	mov ebx,edx
	add eax,ebx
	
	mov esp,ebp
	pop ebp
	ret 
adunare endp

scadere PROC
	push ebp
	mov ebp,esp
	
	mov eax,ecx
	mov ebx,edx
	sub eax,ebx
	
	mov esp,ebp
	pop ebp
	ret 
scadere endp

inmultire PROC
	push ebp
	mov ebp,esp
	
	mov eax,ecx
	mov ebx,edx
	mul ebx
	
	mov esp,ebp
	pop ebp
	ret 
inmultire endp

impartire PROC
	push ebp
	mov ebp,esp 
	
	mov eax,[ebp+8]
	mov ecx,[ebp+12]
	div ecx
	
	mov esp,ebp
	pop ebp
	ret 
impartire endp

start:
hexa:

	push offset expresie
	push offset formats
	call printf
	add esp,8
	
	xor ebx,ebx
	push offset sir1
	push offset formats
	call scanf
	add esp,8
	
	push offset iesire
	push offset sir1
	call strcmp
	add esp,8
	
	cmp eax,0
	je sfarsit
	jne conti2
	
	sfarsit:
		push 0
		call exit
	
	conti2:
	
	push offset mode1
	push offset fisier
	call fopen
	add esp,8
	mov esi,eax
	
	mov bl,sir1[0];la liniile acestea verificam daca primul caracter e + - / *
	cmp bl,43
	je facut
	cmp bl,45
	je facut
	cmp bl,47
	je facut
	cmp bl,42
	jne conti
	je facut
	
	facut:;daca da,atunci prima data punem in fisier suma,si doar dupa aceea(conti:) punem restul sirului
		push suma
		push offset formatx
		push esi
		call fprintf
		add esp,8
		
	conti:
		mov suma,0
		xor ebx,ebx
		push offset sir1
		push offset formats
		push esi
		call fprintf
		add esp,12
	
		push esi
		call fclose
		add esp,4
	
		push offset mode2
		push offset fisier
		call fopen
		add esp,8
		mov pointer,eax
		xor edi,edi
	
	mov contor,0
	
	creare:
		push offset nr
		push offset formatx
		push pointer
		call fscanf
		add esp,12
		
		mov edi,contor
		mov esi,nr
		mov vector[edi],esi
		add contor,4
		
		push offset caracter
		push offset formatc
		push pointer
		call fscanf
		add esp,12
		
		mov edi,contor
		mov esi,caracter
		cmp esi,61
		je gata
		mov vector[edi],esi
		add contor,4
	jne creare
	gata:
		push pointer
		call fclose
		add esp,4
		sub contor,4 ;<------------LUNGIMEA SIRULUI
		mov esi,4
		prima_parte:
			mov esi,4
			aici:
			cmp esi,contor
			jg sfp1;daca am ajuns la capatul sirului,iesim din prima parte,si facem partea a doua("+","-")
			cmp vector[esi],47 ;verificam daca operatorul e impartire
			je i1 ;daca ,da sarim la eticheta i1
			cmp vector[esi],42
			je i2;daca nu,sarim la eticheta i2
			jne schimbare;daca nu e nici "*" nici "/",sarim la schimbare
			i1:
				mov ebx,vector[esi-4] ;operandul inainte de "/"
				mov ecx,vector[esi+4];operandul dupa "/"
				mov im,ecx ;aici punem impartitorul
				mov de,ebx ;aici punem deimpartitul
				push im ;punem pe stiva
				push de
				mov edx,0 ;din motive de siguranta,punem edx pe 0
				call impartire
				mov vector[esi-4],eax ;in pozitia de dinainte de "/"
				eliminare1:
					mov ebx,vector[esi+8] ;cele doua linii facem shiftare
					mov vector[esi],ebx
					add esi,4 ;mergem spre celalalt operator
					cmp esi,contor;verificam daca nu s-a golit expresia in urma operatiilor
					je sf1;daca da,atunci iesim
				jmp eliminare1
			i2:
				mov ecx,vector[esi-4]
				mov edx,vector[esi+4]
				call inmultire
				mov vector[esi-4],eax
				eliminare2:
					mov ebx,vector[esi+8]
					mov vector[esi],ebx
					add esi,4
					cmp esi,contor
					je sf1
				jmp eliminare2
			
				schimbare:
					add esi,8 ;aici trecem la urmatorul operator
					jmp aici ;mai incercam din nou sa cautam "*","/"
				sf1:	
					sub contor,8;inainte am dat de "*" sau "/" scadem din lungimea sirului,trecem la pozitia 4(primul operator) si reluam procesul
				jmp prima_parte
			sfp1:
		doua_parte: ;analog cu partea 1
			mov esi,4
			aici1:
			cmp esi,contor
			jg sfp2
			cmp vector[esi],43
			je i3
			cmp vector[esi],45
			je i4
			i3:
				mov ecx,vector[esi-4]
				mov edx,vector[esi+4]
				call adunare
				mov vector[esi-4],eax
				eliminare3:
					mov ebx,vector[esi+8]
					mov vector[esi],ebx
					add esi,4
					cmp esi,contor
					je sf2
				jmp eliminare3
			i4:
				mov ecx,vector[esi-4]
				mov edx,vector[esi+4]
				call scadere
				mov vector[esi-4],eax
				eliminare4:
					mov ebx,vector[esi+8]
					mov vector[esi],ebx
					add esi,4
					cmp esi,contor
					je sf2
				jmp eliminare4
				sf2:	
					sub contor,8
				jmp doua_parte
		sfp2:
		mov ebx,vector[0];rezultatul final ramane in prima pozitie a vectorului
		mov suma,ebx
		push suma
		push offset formatx
		call printf
		add esp,8
		push backslashn
		push offset formatc
		call printf
		add esp,8
jmp start		
end start
