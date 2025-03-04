with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure Main is

   type matrix is array (1..128, 1..128) of Integer; --MATRIZ PARA IMAGEN
   type binary is array (1..20, 1..8) of Integer; --MATRIZ PARA MENSAJE CODIFICADO
   type arr8 is array (1..8) of Integer; --MATRIZ PARA NUMEROS DE 8 BITS

   procedure bin2Dec (bin: in arr8; dec: out Integer) is --PROCEDIMIENTO PARA PASAR DE BINARIO A DECIMAL
   begin
      dec:=0;
      for I in reverse 2..8 loop --SE HACE AL REVES PORQUE TODOS LOS NUMEROS BINARIOS ESTAN GUARDADOS AL REVES
         dec:=(dec+bin(I))*2; --SE SUMA EL VALOR ACTUAL Y SE MULTIPLICA POR DOS
      end loop;
      if(bin(1)=1) then dec:=dec+1; end if; --AL FINAL SE SUMA EL ULTIMO BIT SI ES UNO
   end bin2Dec;

   procedure dec2Bin (dec : in Integer; bin : out arr8) is --PROCEDIMIENTO PARA PASAR DE DECIMAL A BINARIO
      aux:Integer:=0;
   begin
      aux:=dec;
      for I in 1..8 loop
         bin(I):=aux mod 2; --OBTENEMOS EL RESIDUO Y LO GUARDAMOS (SE GUARDA AL REVES POR COMODIDAD)
         aux:=aux/2; --SE HACE LA DIVISION REAL
      end loop; --SE REPITE HASTA OBTENER LOS 8 BITS
   end dec2Bin;

   procedure MatRead (img : in out matrix; file: in string) is --PROCEDIMIENTO PARA LEER MATRIZ DE IMAGEN
      inFile : File_Type;
   begin
      open(inFile, In_File, file);
      for row in img'Range(1) loop
         for col in img'Range(2) loop
            Ada.Integer_Text_IO.Get(inFile, img(row, col)); --GUARDAMOS FILA POR COLUMNA
         end loop;
      end loop;
      close(inFile);
   end MatRead;

   procedure ReadKey (key : in string; keyTranslate : out arr8; flag : out Boolean) is --PROCEDIMIENTO PARA LEER LA LLAVE
   begin
      if key(key'First)=key(key'First+2) or key(key'First+1)=key(key'First+3) then --LOOP POR SI SE INGRESA UNA LLAVE INCORRECTA
         Put("LLAVE INVALIDA, NO SE PUEDE COMENZAR POR UN LADO Y RECORRER HACIA EL MISMO... CAMBIE LA LLAVE DE 8 DIGITOS: ");
         flag := true;
      else flag:=false;
      end if;
      if key(key'First)='1' then keyTranslate(1):=1; else keyTranslate(1):=128; end if; --ARRIBA/ABAJO
      if key(key'First+1)='1' then keyTranslate(2):=1; else keyTranslate(2):=128; end if; --IZQUIERDA/DERECHA
      if key(key'First+2)='1' then keyTranslate(3):=-1; else keyTranslate(3):=1; end if; --ARRIBA/ABAJO
      if key(key'First+3)='1' then keyTranslate(4):=-1; else keyTranslate(4):=1; end if; --IZQUIERDA/DERECHA
      if key(key'First+4)='1' then keyTranslate(5):=1; else keyTranslate(5):=0; end if; --RENGLON/COLUMNA
      if key(key'First+5)='1' then keyTranslate(6):=2; else keyTranslate(6):=1; end if; --1BIT/2BITS
      keyTranslate(7):=0;
      keyTranslate(8):=0;
   end ReadKey;

   procedure Decr (TransKey : in arr8; bin : out binary; img : in  matrix; message: out string) is --FUNCION PARA DESCENCRIPTAR
      pos_y:Integer:=TransKey(1); --OBTENEMOS LO QUE SE TRADUJO DE LA LLAVE ANTERIORMENTE
      pos_x:Integer:=TransKey(2); --EN ESTA FUNCION SE OBTIENEN LOS BITS MENOS SIGNIFICATIVOS DE LOS PIXELES
      step_y:Integer:=TransKey(3);
      step_x:Integer:=TransKey(4);

      act_bin:arr8; --VARIABLES ACTUALES
      act_dec:Integer;
      act_char:Character;
   begin
      if TransKey(6)=1 then --1BIT
         if TransKey(5)=1 then --RENGLON
            for I in bin'Range(1) loop
               for J in bin'Range(2) loop
                  bin(I,J):=img(pos_y, pos_x) mod 2; --MOD DOS PARA SABER SI EL BIT MENOS SIGNIFICATIVO ES 1 O 0
                  pos_x:=pos_x+step_x; --PASO
               end loop;
               pos_y:=pos_y+step_y; --PASO
               pos_x:=TransKey(2); --REGRESAR A POSICION
            end loop;

         else --COLUMNA
            for I in bin'Range(1) loop
               for J in bin'Range(2) loop
                  bin(I,J):=img(pos_y, pos_x) mod 2;
                  pos_y:=pos_y+step_y; --PASO
               end loop;
               pos_x:=pos_x+step_x; --PASO
               pos_y:=TransKey(1); --REGRESAR A POSICION
            end loop;
         end if;

      else --2 BITS
         if TransKey(5)=1 then --RENGLON
            for I in bin'Range(1) loop
               for J in bin'Range(2) loop
                  if J mod 2=0 then --SOLO SE EJECUTA CUANDO J ES PAR PORQUE ES CADA DOS BITS
                     act_dec:=img(pos_y,pos_x) mod 4; --MOD 4 PARA SABER SI LOS BITS SON 11, 10, 01 O 00
                     dec2Bin(act_dec, act_bin); --SE CONVIERTE EN BINARIO
                     bin(I,J-1):=act_bin(1); --SE COLOCA EL BIT ACTUAL
                     bin(I,J):=act_bin(2); --SE COLOCA EL BIT ACTUAL UNA POSICIÓN MENOS
                       pos_x:=pos_x+step_x; --PASO
                  end if;
               end loop;
               pos_y:=pos_y+step_y; --PASO
               pos_x:=TransKey(2); --REGRESAR A POSICION
            end loop;

         else --COLUMNA
            for I in bin'Range(1) loop --ES IGUAL A LA ANTERIOR PERO AL REVÉS
               for J in bin'Range(2) loop
                  if J mod 2=0 then
                     act_dec:=img(pos_y,pos_x) mod 4;
                     dec2Bin(act_dec, act_bin);
                     bin(I,J-1):=act_bin(1);
                     bin(I,J):=act_bin(2);
                       pos_y:=pos_y+step_y; --PASO
                  end if;
               end loop;
               pos_x:=pos_x+step_x; --PASO
               pos_y:=TransKey(2); --REGRESAR A POSICION
            end loop;
         end if;
      end if;

      for J in 1..20 loop
         for I in 1..8 loop
            act_bin(I):=bin(J,I); --ARMAR LETRAS EN BINARIO
         end loop;
         bin2Dec(act_bin, act_dec); --CONVERTIR BINARIOS A DECIMALES
         act_char:= Character'Val(act_dec); --CONVERTIR DECIMAL A CARACTER
         if act_char in 'A'..'Z' then --SOLO SI ES DE LA A A LA Z
            put(act_char); --ESCRIBIR LETRA ACTUAL
            message(J):=act_char; --ESCRIBIR EL MENSAJE
         else
            put(' '); --PONER ESPACIO SI NO ES A A LA Z
            message(J):=' ';
         end if;
      end loop;
   end Decr;

   img: matrix;
   key:string:="00111000";
   message:string:=(1 .. 20 => ' ');
   keyTrans:arr8;
   keyFlag:Boolean;
   bin:binary;

   bin_mess:File_Type;


begin
   MatRead(img, "imgEnc.txt"); --LEER MATRIZ
   ReadKey(key, keyTrans, keyFlag); --TRADUCIR LLAVE
   Decr(keyTrans, bin, img, message); --DESENCRIPTAR
   Create(bin_mess, Out_File, "BinMess.txt"); --CREAR ARCHIVO PARA EL MENSAJE

   for I in 1..20 loop
      for J in 1..8 loop
         Put(bin_mess, bin(I,J)); --PONER EL MENSAJE EN EL ARCHIVO
      end loop;
      New_Line(bin_mess);
   end loop;
   New_Line;
   Put("MENSAJE GUARDADO EN BinMess.txt");
   Put(bin_mess, message);


end Main;
