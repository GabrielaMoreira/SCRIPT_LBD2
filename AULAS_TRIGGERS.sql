-- AULAS TRIGGER
Um gatilho de banco de dados(trigger) � um procedimento pl/sql que voc� associa a uma tabela.
Quando uma instru��o sql � executada sobre uma tabela e atende a uma condi��o de gatilho, o SGBD aciona automaticamente 
o corpo do gatilho (que � um programa pl/sql).

Os gatilhos s�o usados para impor regras de integridade aos dados e impor complexas condi��es de seguran�a.

Como deve ser utilizado:

a) Qdo uma operacao for executada, a��es relacionadas tamb�m devem ser executadas.
b) Nao h� necessidade de utiliza-lo para opera��es espec�ficas do ORACLE, como para garantir integridade referencial - 
so tomaria tempo do ORACLE sem agregar vantagem.
c) Triggers com mais de 60 linhas devem ser transformados em procedimentos que depois ser�o chamados por ele.
d) Nao crie triggers recursivos.
e) Seja cuidadoso: Um trigger ser� executado toda vez que 1 evento ocorrer, portanto, dependendo do caso, pode tornar lento e trabalhoso em situa��es de muito movimento.

--------------------------------------------------------------------------------------------

Tipos de Trigger
----------------

DML - Eventos de Insert, Update ou Delete em tabelas.
DDL - Eventos Create Table, Alter e Drop Table.

--------------------------------------------------------------------------------------------



Triggers DML
------------

 - Nao usar COMMIT ou ROLLBACK nem alterar chaves primarias �nicas ou estrangeiras.

EVENTO (condi��es) : INSERT, UPDATE, DELETE
TEMPO : BEFORE (antes)
        AFTER  (depois)
nivel  : FOR EACH ROW (a cada linha)
        linha=disparado uma vez para cada linha processada.
        instru��o = disparado uma vez s�, antes ou depois da instru��o.


Restri��es: n�o pode ter commit ou rollback ou savepoints.

Define-se um Gatilho atrav� do comando => create trigger

Qdo mais de 1 evento pode-se usar INSERTING, UPDATING, DELETING

--------------------------------------------------------------------------------------------

Exemplo 1: Este gatilho grava um registro na tabela logteste, 
toda vez que um registro foi excluido da tabela produto*/


create table logteste
(nrlog number primary key, 
 Dttrans date not null, 
 Usuario varchar2(15) not null, 
 Tabela varchar2(30),
 Opera char(1) check (opera in('I','A','E')),
 Linhas Number(5) not Null check(linhas >=0));


/*
LEGENDA:

I - INCLUIDO
A - ALTERADO
E - EXCLUIDO
*/



create sequence seqlog;

select seqlog.currval from dual;


insert into produto values (8,'Caneta','UN', 5.00,30);

	     
Create or Replace trigger EliminaProduto
before delete on produto
for each row
begin
  insert into logteste values(seqlog.nextval,sysdate,user,'produto','E',1);
end Eliminaproduto;



--para testar o trigger


delete produto where cod_produto = 8;
SELECT * FROM LOGTESTE;

/*
Exemplo 2: Este gatilho n�o permite que os usu�rios atualizem ou eliminem registros
 de pacientes antes das 
7:00 da manh� e depois das 14:00
*/

/*ATUALIZA��ES PERMETIDAS APENAS ENTRE 7:00AM E 10:00PM*/
Create or Replace Trigger ChecaHora
before update or  delete on paciente
begin
  if to_number(to_char(sysdate,'HH24')) not between 7 and 10 then
    raise_application_error(-20400,'Altera��es n�o permitidas');
  end if;
end ChecaHora;


update paciente
set nompaciente = 'Carlos Alberto'
where CODPACIENTE = 1;

SELECT * FROM PACIENTE

--Exemplo 3 - igual ao exemplo 2 por�m identificando se o usu�rio tentou fazer update ou delete.



Create or Replace Trigger ChecaHora2
before update or  delete on paciente
begin
  if to_char(sysdate,'HH24') not between 11 and 14 then
    if updating then	
      raise_application_error(-20400,'Update n�o permitido');
    elsif deleting then
      raise_application_error(-20410,'Delete n�o permitido');
    end if;
  end if;
end ChecaHora2;
/

ALTER TRIGGER nome_da_trigger DISABLE; 
ALTER TRIGGER nome_da_trigger enable;




==================================================================
USANDO :new e :old 


Exemplo 1
---------

CREATE or replace TRIGGER Troca_data
BEFORE INSERT ON pedido
FOR EACH ROW
BEGIN
      :NEW.prazo_entrega := SYSDATE + 15;

END;

--testar:
 insert into pedido values (999,'30/10/2017',12589,98521, 20);
 
 select * from pedido;
------------------------------------------------------------------

Exemplo 2
---------			   Memoria
			      ------------------	
:NEW.______       	     |------------------|
			:New  9999 30/10/2010 |
			     |------------------|
			     |			|
			     |                  |	
			      ------------------	




===============================================================

Tabela de valores das vari�veis de mem�ria

		:NEW				             :OLD

INSERT    valores que estao sendo incluidos  Nao definido-null

UPDATE	  valores que modificados         valores originais 	                            		                                   da tabela
	   
DELETE	  Nao Definido-null 	            Dados antes da 
						            dele��o	

--------------------------------------------------------------------------------------------

Exercicio
---------

1- alterar o trigger   elimina_produto para gravar o codigo do produto excluido.

----inserindo um novo produto para teste

 insert into produto values (7,'Caneta','UN', 5.00,30);


Create or Replace trigger EliminaProduto
before delete on produto
for each row
begin
  insert into logteste values
   (seqlog.nextval,sysdate,user,'produto '||:old.cod_produto,'E',1);
end Eliminaproduto;



delete produto
where cod_produto =7;

select * from logteste

Create or Replace trigger updatePedido
before update of prazo_entrega  on pedido
for each row
begin
  insert into logteste values
   (seqlog.nextval,sysdate,user,'pedido '|| :old.prazo_entrega ||
    ' novo: '|| :new.prazo_entrega,'E',1);
end updatepedido;

UPDATE PEDIDO
SET PRAZO_ENTREGA = '02/06/19'
WHERE NUM_PEDIDO = 999;

SELECT * FROM LOGTESTE




create or replace trigger Tx
before  insert or delete or update of endereco on cliente
for each row
begin
   insert into logteste values (seglog.nextval,sysdate,null,null,null,null);
end;



Para j�
=========

 insert into produto values (18,'Caneta','UN', 5.00,30);


1. Escreva um trigger que ao incluir um produto altere
 seu valor unitario multiplicando por 0.8


Create or replace  trigger tr_IncluirPro
before insert on tb_produto
For each row
begin

:New.valor_unit := :new.valor_unit * 0.8;

end;






=====================================================

2. Escreva um trigger que ao alterar o prazo de entrega de um pedido, 
grave na tablog o prazo antigo, prazo novo e o nome do cliente.



create sequence seqtablog;


create table tablog
( numLog number primary key,
  datalog  date,
  usuario  varchar2(15),
  tabela   varchar2(15),
  oldcampo varchar2(30),
  newcampo varchar2(30),
  campo1   varchar2(30));


===================================================================================
outro exemplo: trigger para registrar quem entrou no sistema:

create table sys_vigia
(campo varchar2(200));


CREATE OR REPLACE TRIGGER marca_logon 
   AFTER LOGON ON DATABASE 
BEGIN 
  INSERT INTO sys_vigia 
    VALUES (USER || ' entrou no sistema em ' || 
            TO_CHAR(sysdate, 'DD-MM-YYYY HH24:MI:SS')); 
  COMMIT; 
END; 
/ 

SQL> CREATE OR REPLACE TRIGGER marca_logon 
  2     AFTER LOGON ON DATABASE 
  3  BEGIN 

  4    INSERT INTO sys_vigia 
  5      VALUES (USER || ' entrou no sistema em ' || 
  6              TO_CHAR(sysdate, 'DD-MM-YYYY HH24:MI:SS')); 
  7    COMMIT; 
  8  END; 
  9  / 

Gatilho criado.

SQL> select * from sys_vigia;

CAMPO
--------------------------------------------------------------------
ANGELICA entrou no sistema em 07-05-2009 12:11:17

esta trigger registra o nome do usu�rio e a que horas ele entrou. Esse exemplo foi retirado diretamente da documenta��o Oracle. No nosso exemplo fazemos referencia a um evento do sistema ao inv�s de referenciarmos uma tabela. Outros eventos do sistema s�o: 

- AFTER SERVERERROR 
- AFTER LOGON 
- BEFORE LOGOFF 
- AFTER STARTUP 
- BEFORE SHUTDOWN 


Triggers instead of
=======================



INSTEAD OF indica que a trigger ir� ser executada no lugar da instru��o que disparou a trigger. Literalmente, a instru��o � substitu�da pela trigger. Essa t�cnica permite que fa�amos, por exemplo, altera��es em uma tabela atrav�s de uma view. � usado nos casos em que a view n�o pode alterar uma tabela por n�o referenciar uma coluna com a constraint not null. Nesse caso a trigger pode atualizar a coluna que a view n�o tem acesso. 

Dois detalhes muito importantes sobre INSTEAD OF: 

- S� funcionam com views e 
- � sempre de linha. Ser� considerado assim, mesmo que "FOR EACH ROW" for omitido. 

Exemplo: 
C�digo: 

CREATE OR REPLACE TRIGGER novo_func 
   INSTEAD OF INSERT ON vemp 
FOR EACH ROW 
WHEN ... 
. 
. 
. 
END; 
/ 
 

O evento define qual � a instru��o DML que aciona a trigger. Informa qual instru��o SQL ir� disparar a trigger. Pode ser: 

- INSERT 
- UPDATE 
- DELETE 

