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

-- Deletar Pgts 
DELIMITER $$
CREATE PROCEDURE deletar_pgts(IN p_id_pagamento INT)
BEGIN
    DELETE FROM pagamentos WHERE id_pagamento = p_id_pagamento;
END$$
DELIMITER ;
-- Inserir Pgts 
DELIMITER $$ 
CREATE PROCEDURE inserir_pgts(
	IN p_id_morador INT,
    IN p_id_unidade INT,
    IN p_mes_ref VARCHAR(2),
    IN p_ano_ref VARCHAR(4),
    IN p_data_pagamento DATE,
    IN p_comprovante MEDIUMBLOB
)
BEGIN
	INSERT INTO pagamentos (id_morador, id_unidade, mes_ref, ano_ref, data_pagamento, comprovante)
	VALUES (p_id_morador, p_id_unidade, p_mes_ref, p_ano_ref, p_data_pagamento, p_comprovante);
END $$
DELIMITER ;    

-- Deletar Moradores 
DELIMITER $$
CREATE PROCEDURE deletar_morador(IN p_id_morador INT)
BEGIN
    DELETE FROM moradores WHERE id_morador = p_id_morador;
END$$
DELIMITER ;
-- Inserir Moradores 
DELIMITER $$
CREATE PROCEDURE inserir_morador(
    IN p_nome VARCHAR(200),
    IN p_sobrenome VARCHAR(200),
    IN p_email VARCHAR(200),
    IN p_RG VARCHAR(20),
    IN p_telefone VARCHAR(14)
)
BEGIN
    INSERT INTO moradores (nome, sobrenome, email, RG, telefone)
    VALUES (p_nome, p_sobrenome, p_email, p_RG, p_telefone);
END$$
DELIMITER ;

-- TESTES 
INSERT INTO unidades (loc, id_morador) VALUES  ('Bloco A, Apt 101', 1); -- INSIRIR A UND PARA CONSEGUIR PROCEDECER COM ALGUSN DELETE E SELECT
CALL inserir_morador('Nome1', 'Nome1.0', 'Nome1@email.com', '123456789', '(11) 1111-1111');
SELECT * FROM moradores;
DELETE FROM unidades WHERE id_morador = 1;
CALL deletar_morador(1);
CALL inserir_pgts(1, 1, '11', '2025', '2025-11-30', 'comprovante');
SELECT * FROM pagamentos;
CALL deletar_pgts(1);

-- View Pgts - Ordenado
CREATE VIEW pgts_lista AS
SELECT 
    p.id_pagamento,
    CONCAT(m.nome, ' ', m.sobrenome) AS nome_pagador,
    p.data_pagamento,
    p.mes_ref,
    p.ano_ref,
    u.loc AS localizacao_unidade,
    p.data_reg
FROM pagamentos p
INNER JOIN moradores m ON p.id_morador = m.id_morador
INNER JOIN unidades u ON p.id_unidade = u.id_unidade
ORDER BY p.ano_ref, p.mes_ref;
-- TESTE
SELECT * FROM pgts_lista;

-- Partes_Faltantes
-- Trigger para Data_Pagamento (RNF06)
-- Procedure - Inserir e Deletar UNDS


-- obs
-- IN (padrão): Parâmetro de entrada apenas - você ENVIA dados do JS para a stored procedure
-- OUT: Parâmetro de saída - a stored procedure RETORNA um valor por esse parâmetro
-- INOUT: Entrada e saída - você envia e recebe pelo mesmo parâmetro


