use M3;

create user server@localhost identified by 'Senha@123';

grant EXECUTE on *.* to server@localhost;

create table moradores(
	id_morador int primary key auto_increment,
    nome varchar(200),
    sobrenome varchar(200),
    email varchar(200),
    RG varchar(9),
    telefone varchar(14)
);

create table unidades(
	id_unidade int primary key auto_increment,
    loc varchar(50),
    id_morador int,
    foreign key (id_morador) references moradores(id_morador)
);


create table pagamentos(
	id_pagamento int auto_increment primary key,
    id_morador int,
    data_pagamento varchar(10),
    comprovante MEDIUMBLOB,
    mes_ref varchar(2),
    ano_ref varchar(4),
    id_unidade int,
    data_reg varchar(10),
	foreign key (id_morador) references moradores(id_morador),
    foreign key (id_unidade) references unidades(id_unidade)
);



CALL cadastra_moradores('João Matheus', 'de Oliveira Vieira', 'exemplo@exemplo.com.br', '0.000.000', '48991098811');

select * from moradores;

-- Inserir UNDS
DELIMITER $$
CREATE PROCEDURE inserir_unds(
	IN p_loc VARCHAR(50),
    IN p_id_morador INT
)
BEGIN 
	INSERT INTO unidades (loc, id_morador)
	VALUES (p_loc, p_id_morador);
END$$
DELIMITER ;
-- Deletar UNDS
DELIMITER $$
CREATE PROCEDURE deletar_unds(IN p_id_unidade INT)
BEGIN
    DELETE FROM unidades WHERE id_unidade = p_id_unidade;
END$$
DELIMITER ;
-- TESTE
CALL inserir_morador('Nome1', 'Nome1.0', 'Nome1@email.com', '123456789', '(11) 1111-1111');
SELECT * FROM moradores;
CALL inserir_unds('Bloco A, Apt 101', 2);
SELECT * FROM unidades;
CALL deletar_unds(3);
CALL deletar_morador(2);

-- Trigger para Data_Pagamento (RNF06)
DELIMITER $$
CREATE TRIGGER data_registro_pgt
BEFORE INSERT ON pagamentos
FOR EACH ROW
BEGIN
    IF NEW.data_reg IS NULL THEN
        SET NEW.data_reg = NOW();
    END IF;
END$$
DELIMITER ;
-- TESTES
-- Inserir um morador
CALL inserir_morador('Nome2', 'Trigger Test', 'Nome2@email.com', '987654321', '(22) 2222-2222');
SELECT * FROM moradores;
-- Inserir uma unidade
CALL inserir_unds('Bloco B, Apt 202', 1);
SELECT * FROM unidades;

-- 2. Teste 1: Inserir pagamento SEM informar data_reg (deve ser preenchida automaticamente)
CALL inserir_pgts(1, 1, '12', '2024', '2024-12-01', 'comprovante_1');
-- 3. Verificar o resultado
SELECT * FROM pagamentos;
-- 4. Teste 2: Inserir outro pagamento INFORMANDO data_reg (deve manter o valor informado)
CALL inserir_pgts(1, 1, '11', '2024', '2024-11-30', 'comprovante_teste2');
-- 5. Verificar ambos os registros
SELECT 
    id_pagamento,
    mes_ref,
    ano_ref,
    data_pagamento,
    data_reg
FROM pagamentos;


