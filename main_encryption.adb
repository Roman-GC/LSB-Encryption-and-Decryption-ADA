--GARNICA CORTES ROMAN
--CONTRERAS GUTIERREZ CYNTHIA

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure Main is

   type matrix is array (1..128, 1..128) of Integer; --MATRIZ PARA IMAGEN
   type binary is array (1..20, 1..8) of Integer; --MATRIZ PARA MENSAJE CODIFICADO
   type arr8 is array (1..8) of Integer; --MATRIZ PARA NUMEROS DE 8 BITS

   procedure dec2Bin (dec : in Integer; bin : out arr8) is --PROCEDIMIENTO PARA PASAR DE DECIMAL A BINARIO
      aux:Integer:=0;
   begin
      aux:=dec;
      for I in 1..8 loop
         bin(I):=aux mod 2; --OBTENEMOS EL RESIDUO Y LO GUARDAMOS (SE GUARDA AL REVES POR COMODIDAD)
         aux:=aux/2; --SE HACE LA DIVISION REAL
      end loop; --SE REPITE HASTA OBTENER LOS 8 BITS
   end dec2Bin;

   procedure bin2Dec (bin: in arr8; dec: out Integer) is --PROCEDIMIENTO PARA PASAR DE BINARIO A DECIMAL
   begin
      dec:=0;
      for I in reverse 2..8 loop --SE HACE AL REVES PORQUE TODOS LOS NUMEROS BINARIOS ESTAN GUARDADOS AL REVES
         dec:=(dec+bin(I))*2; --SE SUMA EL VALOR ACTUAL Y SE MULTIPLICA POR DOS
      end loop;
      if(bin(1)=1) then dec:=dec+1; end if; --AL FINAL SE SUMA EL ULTIMO BIT SI ES UNO
   end bin2Dec;

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

   procedure Char2Bin (mess: in string; bin : out binary) is --PROCEDIMIENTO PARA ENCRIPTAR TEXTO
      charVal : Integer;
      char:Character;
   begin
      for J in mess'Range loop
         char:=mess(J);
         if char in 'A'..'Z' then
            charVal := Character'Pos(char); --SE OBTIENE VALOR NUMERICO DE LA LETRA
            for I in 1..8 loop
               bin(J,I):= charVal mod 2; --SE CONVIERTE A BINARIO
               charVal := charVal/2;
            end loop;
         end if;
      end loop; --SE REPITE HASTA LLENAR LA MATRIZ DE 20X8
   end Char2Bin;

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

   procedure Encr (TransKey : in arr8; bin : in binary; img : in out matrix) is --FUNCION PARA ENCRIPTAR
      pos_y:Integer:=TransKey(1); --OBTENEMOS LO QUE SE TRADUJO DE LA LLAVE ANTERIORMENTE
      pos_x:Integer:=TransKey(2);
      step_y:Integer:=TransKey(3);
      step_x:Integer:=TransKey(4);

      act_bin:arr8; --VARIABLES ACTUALES
      act_dec:Integer;
   begin
      if TransKey(6)=1 then --1BIT
         if TransKey(5)=1 then --RENGLON
            for I in bin'Range(1) loop
               for J in bin'Range(2) loop
                  dec2Bin(img(pos_y, pos_x), act_bin);
                  act_bin(1):=bin(I,J);
                  bin2Dec(act_bin, act_dec);
                  img(pos_y, pos_x):=act_dec;
                  pos_x:=pos_x+step_x;
               end loop;
               pos_y:=pos_y+step_y;
               pos_x:=TransKey(2);
            end loop;

         else --COLUMNA
            for I in bin'Range(1) loop --EXACTAMENTE LO MISMO QUE LA PASADA PERO CAMBIO DE EJES
               for J in bin'Range(2) loop
                  dec2Bin(img(pos_y, pos_x), act_bin);
                  act_bin(1):=bin(I,J);
                  bin2Dec(act_bin, act_dec);
                  img(pos_y, pos_x):=act_dec;
                  pos_y:=pos_y+step_y;
               end loop;
               pos_x:=pos_x+step_x;
               pos_y:=TransKey(1);
            end loop;
         end if;

      else --2 BITS
         if TransKey(5)=1 then --RENGLON
            for I in bin'Range(1) loop
               for J in bin'Range(2) loop
                  if J mod 2 = 0 then --ESTE CONDICIONAL NOS PERMITE IR ESCRIBIENDO DE DOS EN DOS
                     dec2Bin(img(pos_y, pos_x), act_bin); --DEC A BIN
                     act_bin(1):=bin(I,J-1);  --BIT MENOS SIGNIFICATIVO DEL PIXEL IGUAL A BIT ANTERIOR
                     act_bin(2):=bin(I,J); --SEGUNDO MENOS SIGNIFICATIVO IGUAL A BIT ACTUAL
                     bin2Dec(act_bin, act_dec); --REGRESAR A DECIMAL
                     img(pos_y, pos_x):=act_dec; --IGUALAR PIXEL CON DECIMAL ACTUAL
                     pos_x:=pos_x+step_x; --PASO
                  end if;
               end loop;
               pos_y:=pos_y+step_y; --PASO
               pos_x:=TransKey(2); --REGRESAR AL PRINCIPIO
            end loop;

         else --COLUMNA
            for I in bin'Range(1) loop
               for J in bin'Range(2) loop
                  if J mod 2 = 0 then --EXACTAMENTE LO MISMO QUE LA ANTERIOR CON CAMBIO DE EJES
                     dec2Bin(img(pos_y, pos_x), act_bin);
                     act_bin(1):=bin(I,J-1);
                     act_bin(2):=bin(I,J);
                     bin2Dec(act_bin, act_dec);
                     img(pos_y, pos_x):=act_dec;
                     pos_y:=pos_y+step_y;
                  end if;
               end loop;
               pos_x:=pos_x+step_x;
               pos_y:=TransKey(1);
            end loop;
         end if;
      end if;
   end Encr;

   key:string:="00111000"; --IMPORTANTE!!! AQUI SE CAMBIA LA LLAVE
   chars:string:="DISENO DE SOFTWARE S"; --AQUI SE CAMBIA EL MENSAJE
   keyTranslate:arr8;

   bin:binary;

   img:matrix;

   key_lenght:Integer:=8;
   mess_lenght:Integer;

   mat_out: File_Type;
   img_enc: File_Type;

   key_flag:Boolean:=false;

begin

   mess_lenght:=chars'Length;

   for I in chars'Range loop --CONDICIONES DE ERROR EN EL MENSAJE
      if not ((chars(I) in 'A'..'Z') or (chars(I) = ' '))  or mess_lenght/=20 then
         Put_Line("MENSAJE INVALIDO... SE DETUVO LA EJECUCION, INTENTE CON OTRO MENSAJE");
         return;
      end if;
   end loop;

   MatRead(img, "kikinMatrix.txt"); --SE LEE IMAGEN IMAGEN
   Char2Bin(chars, bin); --SE ENCRIPTA MENSAJE
   Create(mat_out, Out_File, "BinaryMess.txt"); --SE CREA ARCHIVO PARA ENCRIPTACION

   for I in bin'Range(1) loop --SE GUARDA LA MATRIZ DE ENCRIPTADO EN TXT PARA OBSERVACION
      Put(mat_out, chars(I));
      Put(mat_out, Character'Pos(chars(I)));
      for J in bin'Range(2) loop
         Put(mat_out, (bin(I,J)));
      end loop;
      New_Line(mat_out);
   end loop;

   loop
      ReadKey(key, keyTranslate, key_flag); --SE LEE LA LLAVE
      if key_flag = True then --SI NO CUMPLE LO REQUERIDO PIDE REESCRIBIR
         Get_Line(key, key_lenght);
      end if;
      exit when key_flag = False;
   end loop;

   Encr(keyTranslate, bin, img); --ENCRIPTADO

   Create(img_enc, Out_File, "ImgEnc.csv"); --ARCHIVO DE SALIDA PARA ENCRIPTADO
   for I in 1..128 loop
      for J in 1..128 loop
         Put(img_enc, img(I, J)); --ESCRIBIMOS ARCHIVO
         if J/=128 then
            Put(img_enc, ","); --COMAS POR FORMATO
         end if;
      end loop;
      New_Line(img_enc); --SALTO DE LINEA CADA QUE TERMINA UNA FILA
   end loop;

   Put_Line("EL MENSAJE SE HA CIFRADO EN LA IMAGEN...");

end Main;
