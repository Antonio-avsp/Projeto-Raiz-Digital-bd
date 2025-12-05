-- =====================================================
-- SCRIPT 1: DDL - CRIAÇÃO DE TABELAS E VIEWS
-- Sistema: Raiz Digital
-- Banco de Dados: MySQL
-- =====================================================

-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS raiz_digital;
USE raiz_digital;

-- =====================================================
-- TABELAS PRINCIPAIS
-- =====================================================

-- Tabela de Usuários
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    telefone VARCHAR(15),
    perfil ENUM('GESTOR', 'OPERADOR', 'AGENTE', 'CIDADAO') NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acesso TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_perfil (perfil)
) ENGINE=InnoDB;

-- Tabela de Espécies de Sementes
CREATE TABLE especies (
    id_especie INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    nome_cientifico VARCHAR(150),
    categoria VARCHAR(50),
    periodo_validade_dias INT NOT NULL,
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_nome (nome)
) ENGINE=InnoDB;

-- Tabela de Fornecedores
CREATE TABLE fornecedores (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    razao_social VARCHAR(150) NOT NULL,
    nome_fantasia VARCHAR(150),
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    inscricao_estadual VARCHAR(20),
    email VARCHAR(100),
    telefone VARCHAR(15),
    endereco VARCHAR(200),
    cidade VARCHAR(100),
    estado CHAR(2),
    cep VARCHAR(9),
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_cnpj (cnpj)
) ENGINE=InnoDB;

-- Tabela de Armazéns
CREATE TABLE armazens (
    id_armazem INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    capacidade_kg DECIMAL(12,2) NOT NULL,
    endereco VARCHAR(200),
    cidade VARCHAR(100),
    estado CHAR(2),
    cep VARCHAR(9),
    responsavel VARCHAR(100),
    telefone VARCHAR(15),
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_codigo (codigo),
    INDEX idx_cidade (cidade)
) ENGINE=InnoDB;

-- Tabela de Municípios
CREATE TABLE municipios (
    id_municipio INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    codigo_ibge VARCHAR(7) UNIQUE NOT NULL,
    estado CHAR(2) NOT NULL,
    populacao_rural INT,
    area_agricola_hectares DECIMAL(12,2),
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_nome (nome),
    INDEX idx_estado (estado)
) ENGINE=InnoDB;

-- Tabela de Agricultores/Beneficiários
CREATE TABLE agricultores (
    id_agricultor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    rg VARCHAR(20),
    data_nascimento DATE,
    email VARCHAR(100),
    telefone VARCHAR(15),
    id_municipio INT NOT NULL,
    endereco VARCHAR(200),
    area_cultivo_hectares DECIMAL(10,2),
    tipo_produtor ENUM('INDIVIDUAL', 'COOPERATIVA', 'ASSOCIACAO') NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_municipio) REFERENCES municipios(id_municipio),
    INDEX idx_cpf (cpf),
    INDEX idx_municipio (id_municipio)
) ENGINE=InnoDB;

-- Tabela de Lotes de Sementes
CREATE TABLE lotes (
    id_lote INT AUTO_INCREMENT PRIMARY KEY,
    numero_lote VARCHAR(50) UNIQUE NOT NULL,
    id_especie INT NOT NULL,
    id_fornecedor INT NOT NULL,
    id_armazem INT NOT NULL,
    quantidade_kg DECIMAL(10,2) NOT NULL,
    quantidade_atual_kg DECIMAL(10,2) NOT NULL,
    data_fabricacao DATE NOT NULL,
    data_validade DATE NOT NULL,
    valor_unitario DECIMAL(10,2),
    qr_code VARCHAR(255) UNIQUE,
    status ENUM('DISPONIVEL', 'EM_TRANSITO', 'VENCIDO', 'ESGOTADO') DEFAULT 'DISPONIVEL',
    observacoes TEXT,
    data_entrada TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_especie) REFERENCES especies(id_especie),
    FOREIGN KEY (id_fornecedor) REFERENCES fornecedores(id_fornecedor),
    FOREIGN KEY (id_armazem) REFERENCES armazens(id_armazem),
    INDEX idx_numero_lote (numero_lote),
    INDEX idx_status (status),
    INDEX idx_validade (data_validade)
) ENGINE=InnoDB;

-- Tabela de Movimentações de Estoque
CREATE TABLE movimentacoes (
    id_movimentacao INT AUTO_INCREMENT PRIMARY KEY,
    id_lote INT NOT NULL,
    tipo_movimentacao ENUM('ENTRADA', 'SAIDA', 'TRANSFERENCIA', 'AJUSTE') NOT NULL,
    id_armazem_origem INT,
    id_armazem_destino INT,
    quantidade_kg DECIMAL(10,2) NOT NULL,
    saldo_anterior_kg DECIMAL(10,2) NOT NULL,
    saldo_atual_kg DECIMAL(10,2) NOT NULL,
    id_usuario INT NOT NULL,
    data_movimentacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo VARCHAR(200),
    observacoes TEXT,
    FOREIGN KEY (id_lote) REFERENCES lotes(id_lote),
    FOREIGN KEY (id_armazem_origem) REFERENCES armazens(id_armazem),
    FOREIGN KEY (id_armazem_destino) REFERENCES armazens(id_armazem),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    INDEX idx_lote (id_lote),
    INDEX idx_data (data_movimentacao),
    INDEX idx_tipo (tipo_movimentacao)
) ENGINE=InnoDB;

-- Tabela de Ordens de Expedição
CREATE TABLE ordens_expedicao (
    id_ordem INT AUTO_INCREMENT PRIMARY KEY,
    numero_ordem VARCHAR(50) UNIQUE NOT NULL,
    id_armazem INT NOT NULL,
    id_municipio INT NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_prevista_entrega DATE NOT NULL,
    data_expedicao TIMESTAMP NULL,
    status ENUM('PENDENTE', 'EM_TRANSITO', 'ENTREGUE', 'CANCELADA') DEFAULT 'PENDENTE',
    id_usuario_criacao INT NOT NULL,
    id_usuario_expedicao INT,
    observacoes TEXT,
    FOREIGN KEY (id_armazem) REFERENCES armazens(id_armazem),
    FOREIGN KEY (id_municipio) REFERENCES municipios(id_municipio),
    FOREIGN KEY (id_usuario_criacao) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_usuario_expedicao) REFERENCES usuarios(id_usuario),
    INDEX idx_numero_ordem (numero_ordem),
    INDEX idx_status (status),
    INDEX idx_data_prevista (data_prevista_entrega)
) ENGINE=InnoDB;

-- Tabela de Itens da Ordem de Expedição
CREATE TABLE itens_ordem (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_ordem INT NOT NULL,
    id_lote INT NOT NULL,
    quantidade_kg DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_ordem) REFERENCES ordens_expedicao(id_ordem) ON DELETE CASCADE,
    FOREIGN KEY (id_lote) REFERENCES lotes(id_lote),
    INDEX idx_ordem (id_ordem),
    INDEX idx_lote (id_lote)
) ENGINE=InnoDB;

-- Tabela de Entregas/Distribuições
CREATE TABLE entregas (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_ordem INT NOT NULL,
    id_agricultor INT NOT NULL,
    id_lote INT NOT NULL,
    quantidade_kg DECIMAL(10,2) NOT NULL,
    data_entrega TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_usuario_entrega INT NOT NULL,
    comprovante_path VARCHAR(255),
    assinatura_digital TEXT,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    observacoes TEXT,
    FOREIGN KEY (id_ordem) REFERENCES ordens_expedicao(id_ordem),
    FOREIGN KEY (id_agricultor) REFERENCES agricultores(id_agricultor),
    FOREIGN KEY (id_lote) REFERENCES lotes(id_lote),
    FOREIGN KEY (id_usuario_entrega) REFERENCES usuarios(id_usuario),
    INDEX idx_ordem (id_ordem),
    INDEX idx_agricultor (id_agricultor),
    INDEX idx_data (data_entrega)
) ENGINE=InnoDB;

-- Tabela de Log de Auditoria
CREATE TABLE auditoria (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    tabela VARCHAR(50) NOT NULL,
    operacao ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    id_registro INT NOT NULL,
    id_usuario INT,
    dados_antigos JSON,
    dados_novos JSON,
    data_operacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_origem VARCHAR(45),
    INDEX idx_tabela (tabela),
    INDEX idx_data (data_operacao)
) ENGINE=InnoDB;

-- =====================================================
-- SCRIPT DE POPULAÇÃO DE DADOS (INSERTS - DML)
-- =====================================================
USE raiz_digital;

-- 1. Inserindo Usuários (20 registros)
INSERT INTO usuarios (nome, email, senha_hash, cpf, telefone, perfil, ativo) VALUES 
('João Silva', 'joao.admin@raiz.com', 'hash123', '11122233301', '81999990001', 'GESTOR', TRUE),
('Maria Santos', 'maria.op@raiz.com', 'hash123', '11122233302', '81999990002', 'OPERADOR', TRUE),
('Pedro Oliveira', 'pedro.ag@raiz.com', 'hash123', '11122233303', '81999990003', 'AGENTE', TRUE),
('Ana Souza', 'ana.cid@raiz.com', 'hash123', '11122233304', '81999990004', 'CIDADAO', TRUE),
('Carlos Lima', 'carlos.gestor@raiz.com', 'hash123', '11122233305', '81999990005', 'GESTOR', TRUE),
('Fernanda Costa', 'fernanda.op@raiz.com', 'hash123', '11122233306', '81999990006', 'OPERADOR', TRUE),
('Roberto Alves', 'roberto.ag@raiz.com', 'hash123', '11122233307', '81999990007', 'AGENTE', TRUE),
('Patricia Rocha', 'patricia.cid@raiz.com', 'hash123', '11122233308', '81999990008', 'CIDADAO', TRUE),
('Lucas Mendes', 'lucas.op@raiz.com', 'hash123', '11122233309', '81999990009', 'OPERADOR', TRUE),
('Juliana Martins', 'juliana.ag@raiz.com', 'hash123', '11122233310', '81999990010', 'AGENTE', TRUE),
('Marcos Pereira', 'marcos.cid@raiz.com', 'hash123', '11122233311', '81999990011', 'CIDADAO', TRUE),
('Beatriz Ferreira', 'beatriz.op@raiz.com', 'hash123', '11122233312', '81999990012', 'OPERADOR', TRUE),
('Gabriel Gomes', 'gabriel.ag@raiz.com', 'hash123', '11122233313', '81999990013', 'AGENTE', TRUE),
('Larissa Dias', 'larissa.cid@raiz.com', 'hash123', '11122233314', '81999990014', 'CIDADAO', TRUE),
('Felipe Barbosa', 'felipe.op@raiz.com', 'hash123', '11122233315', '81999990015', 'OPERADOR', TRUE),
('Camila Ribeiro', 'camila.ag@raiz.com', 'hash123', '11122233316', '81999990016', 'AGENTE', TRUE),
('Thiago Araujo', 'thiago.cid@raiz.com', 'hash123', '11122233317', '81999990017', 'CIDADAO', TRUE),
('Renata Cardoso', 'renata.op@raiz.com', 'hash123', '11122233318', '81999990018', 'OPERADOR', TRUE),
('Bruno Castro', 'bruno.ag@raiz.com', 'hash123', '11122233319', '81999990019', 'AGENTE', TRUE),
('Vanessa Pires', 'vanessa.cid@raiz.com', 'hash123', '11122233320', '81999990020', 'CIDADAO', TRUE);

-- 2. Inserindo Espécies (20 registros)
INSERT INTO especies (nome, nome_cientifico, categoria, periodo_validade_dias, descricao) VALUES 
('Milho Crioulo', 'Zea mays', 'Grãos', 365, 'Variedade tradicional resistente a seca.'),
('Feijão Macassar', 'Vigna unguiculata', 'Leguminosa', 365, 'Feijão de corda adaptado ao semiárido.'),
('Arroz Vermelho', 'Oryza sativa', 'Grãos', 300, 'Arroz da terra, rico em ferro.'),
('Mandioca Mansa', 'Manihot esculenta', 'Tubérculo', 120, 'Manivas selecionadas para plantio.'),
('Sorgo Forrageiro', 'Sorghum bicolor', 'Forrageira', 365, 'Para alimentação animal.'),
('Abóbora Leite', 'Cucurbita moschata', 'Hortaliça', 180, 'Sementes de abóbora tradicional.'),
('Melancia Forrageira', 'Citrullus lanatus', 'Forrageira', 365, 'Resistente, para alimentação animal.'),
('Gergelim Branco', 'Sesamum indicum', 'Oleaginosa', 365, 'Rico em óleo.'),
('Girassol', 'Helianthus annuus', 'Oleaginosa', 240, 'Para produção de óleo e forragem.'),
('Algodão Mocó', 'Gossypium hirsutum', 'Fibra', 365, 'Algodão arbóreo nativo.'),
('Fava Larga', 'Phaseolus lunatus', 'Leguminosa', 365, 'Variedade trepadeira.'),
('Amendoim Vermelho', 'Arachis hypogaea', 'Oleaginosa', 180, 'Semente de amendoim tradicional.'),
('Feijão Guandu', 'Cajanus cajan', 'Leguminosa', 365, 'Excelente fixador de nitrogênio.'),
('Batata Doce Roxa', 'Ipomoea batatas', 'Tubérculo', 90, 'Ramas para plantio.'),
('Quiabo Santa Cruz', 'Abelmoschus esculentus', 'Hortaliça', 365, 'Variedade rústica.'),
('Coentro Verdão', 'Coriandrum sativum', 'Hortaliça', 180, 'Sementes com alta germinação.'),
('Pimenta Malagueta', 'Capsicum frutescens', 'Condimento', 365, 'Sementes selecionadas.'),
('Tomate Cereja', 'Solanum lycopersicum', 'Hortaliça', 365, 'Pequeno porte, resistente.'),
('Maracujá do Mato', 'Passiflora cincinnata', 'Frutífera', 180, 'Espécie nativa da Caatinga.'),
('Caju Anão', 'Anacardium occidentale', 'Frutífera', 120, 'Sementes (castanhas) para mudas.');

-- 3. Inserindo Fornecedores (20 registros)
INSERT INTO fornecedores (razao_social, cnpj, cidade, estado, ativo) VALUES 
('Sementes do Vale Ltda', '12345678000101', 'Petrolina', 'PE', TRUE),
('AgroForte S.A.', '12345678000102', 'Juazeiro', 'BA', TRUE),
('Coop. Agricola Sertão', '12345678000103', 'Patos', 'PB', TRUE),
('BioSementes Brasil', '12345678000104', 'Recife', 'PE', TRUE),
('Nativa Insumos', '12345678000105', 'Maceió', 'AL', TRUE),
('Verde Vida Agrícola', '12345678000106', 'Caruaru', 'PE', TRUE),
('Sementes Potiguar', '12345678000107', 'Natal', 'RN', TRUE),
('AgroCearense', '12345678000108', 'Fortaleza', 'CE', TRUE),
('Raízes do Campo', '12345678000109', 'Feira de Santana', 'BA', TRUE),
('Solo Fértil Insumos', '12345678000110', 'Garanhuns', 'PE', TRUE),
('Plantar e Colher Ltda', '12345678000111', 'Aracaju', 'SE', TRUE),
('Sementes da Terra', '12345678000112', 'Teresina', 'PI', TRUE),
('AgroMaranhão', '12345678000113', 'São Luís', 'MA', TRUE),
('EcoSementes', '12345678000114', 'Campina Grande', 'PB', TRUE),
('Vida no Campo', '12345678000115', 'Vitória da Conquista', 'BA', TRUE),
('Insumos Agrícolas NE', '12345678000116', 'João Pessoa', 'PB', TRUE),
('Sementes Selecionadas', '12345678000117', 'Mossoró', 'RN', TRUE),
('AgroTech Sementes', '12345678000118', 'Sobral', 'CE', TRUE),
('Cultivar Ltda', '12345678000119', 'Picos', 'PI', TRUE),
('Sementes do Agreste', '12345678000120', 'Arapiraca', 'AL', TRUE);

-- 4. Inserindo Armazéns (20 registros)
INSERT INTO armazens (nome, codigo, capacidade_kg, cidade, estado) VALUES 
('Armazém Central Recife', 'ARM-001', 50000.00, 'Recife', 'PE'),
('CD Caruaru', 'ARM-002', 30000.00, 'Caruaru', 'PE'),
('CD Petrolina', 'ARM-003', 40000.00, 'Petrolina', 'PE'),
('CD Garanhuns', 'ARM-004', 25000.00, 'Garanhuns', 'PE'),
('CD Serra Talhada', 'ARM-005', 20000.00, 'Serra Talhada', 'PE'),
('CD Salgueiro', 'ARM-006', 20000.00, 'Salgueiro', 'PE'),
('CD Arcoverde', 'ARM-007', 15000.00, 'Arcoverde', 'PE'),
('CD Ouricuri', 'ARM-008', 15000.00, 'Ouricuri', 'PE'),
('CD Afogados', 'ARM-009', 10000.00, 'Afogados da Ingazeira', 'PE'),
('CD Palmares', 'ARM-010', 10000.00, 'Palmares', 'PE'),
('CD Carpina', 'ARM-011', 10000.00, 'Carpina', 'PE'),
('CD Vitória', 'ARM-012', 12000.00, 'Vitória de Santo Antão', 'PE'),
('CD Surubim', 'ARM-013', 8000.00, 'Surubim', 'PE'),
('CD Pesqueira', 'ARM-014', 8000.00, 'Pesqueira', 'PE'),
('CD Gravatá', 'ARM-015', 8000.00, 'Gravatá', 'PE'),
('CD Limoeiro', 'ARM-016', 8000.00, 'Limoeiro', 'PE'),
('CD Santa Cruz', 'ARM-017', 10000.00, 'Santa Cruz do Capibaribe', 'PE'),
('CD São Bento', 'ARM-018', 5000.00, 'São Bento do Una', 'PE'),
('CD Lajedo', 'ARM-019', 5000.00, 'Lajedo', 'PE'),
('CD Belo Jardim', 'ARM-020', 5000.00, 'Belo Jardim', 'PE');

-- 5. Inserindo Municípios (20 registros)
INSERT INTO municipios (nome, codigo_ibge, estado, populacao_rural) VALUES 
('Recife', '2611606', 'PE', 5000),
('Caruaru', '2604106', 'PE', 35000),
('Petrolina', '2611101', 'PE', 45000),
('Garanhuns', '2606002', 'PE', 20000),
('Serra Talhada', '2613909', 'PE', 18000),
('Salgueiro', '2612208', 'PE', 12000),
('Arcoverde', '2601201', 'PE', 8000),
('Ouricuri', '2609907', 'PE', 15000),
('Afogados da Ingazeira', '2600054', 'PE', 9000),
('Palmares', '2609600', 'PE', 7000),
('Carpina', '2604007', 'PE', 5000),
('Vitória de Santo Antão', '2616407', 'PE', 10000),
('Surubim', '2614501', 'PE', 8000),
('Pesqueira', '2610905', 'PE', 11000),
('Gravatá', '2606408', 'PE', 7000),
('Limoeiro', '2608909', 'PE', 9000),
('Santa Cruz do Capibaribe', '2612505', 'PE', 3000),
('São Bento do Una', '2612604', 'PE', 12000),
('Lajedo', '2608800', 'PE', 6000),
('Belo Jardim', '2601706', 'PE', 10000);

-- 6. Inserindo Agricultores (20 registros)
INSERT INTO agricultores (nome, cpf, id_municipio, tipo_produtor, ativo) VALUES 
('José da Silva', '99988877701', 2, 'INDIVIDUAL', TRUE),
('Associação Serra Verde', '99988877702', 4, 'ASSOCIACAO', TRUE),
('Maria da Penha', '99988877703', 5, 'INDIVIDUAL', TRUE),
('Coop. Agreste', '99988877704', 2, 'COOPERATIVA', TRUE),
('Antonio Carlos', '99988877705', 3, 'INDIVIDUAL', TRUE),
('Sebastião Alves', '99988877706', 8, 'INDIVIDUAL', TRUE),
('Francisca Maria', '99988877707', 6, 'INDIVIDUAL', TRUE),
('Associação Mulheres Rurais', '99988877708', 9, 'ASSOCIACAO', TRUE),
('Pedro Santos', '99988877709', 18, 'INDIVIDUAL', TRUE),
('Josefa Lima', '99988877710', 7, 'INDIVIDUAL', TRUE),
('Manoel Ferreira', '99988877711', 14, 'INDIVIDUAL', TRUE),
('Raimundo Nonato', '99988877712', 3, 'INDIVIDUAL', TRUE),
('Associação Vale Fértil', '99988877713', 19, 'ASSOCIACAO', TRUE),
('Paulo Roberto', '99988877714', 12, 'INDIVIDUAL', TRUE),
('Ana Lucia', '99988877715', 11, 'INDIVIDUAL', TRUE),
('Luiz Gonzaga', '99988877716', 5, 'INDIVIDUAL', TRUE),
('Maria José', '99988877717', 15, 'INDIVIDUAL', TRUE),
('Coop. Leiteira', '99988877718', 18, 'COOPERATIVA', TRUE),
('Carlos Eduardo', '99988877719', 20, 'INDIVIDUAL', TRUE),
('Sandra Regina', '99988877720', 10, 'INDIVIDUAL', TRUE);

-- 7. Inserindo Lotes (20 registros)
INSERT INTO lotes (numero_lote, id_especie, id_fornecedor, id_armazem, quantidade_kg, quantidade_atual_kg, data_fabricacao, data_validade) VALUES 
('LOTE-001', 1, 1, 1, 1000.00, 1000.00, '2023-01-01', '2024-01-01'),
('LOTE-002', 2, 2, 2, 500.00, 500.00, '2023-02-01', '2024-02-01'),
('LOTE-003', 1, 3, 3, 800.00, 800.00, '2023-03-01', '2024-03-01'),
('LOTE-004', 3, 4, 1, 600.00, 600.00, '2023-04-01', '2024-04-01'),
('LOTE-005', 4, 1, 4, 1200.00, 1200.00, '2023-05-01', '2023-09-01'),
('LOTE-006', 2, 5, 2, 400.00, 400.00, '2023-06-01', '2024-06-01'),
('LOTE-007', 5, 6, 5, 2000.00, 2000.00, '2023-07-01', '2024-07-01'),
('LOTE-008', 6, 2, 6, 300.00, 300.00, '2023-08-01', '2024-02-01'),
('LOTE-009', 1, 3, 2, 1000.00, 1000.00, '2023-09-01', '2024-09-01'),
('LOTE-010', 7, 7, 3, 500.00, 500.00, '2023-10-01', '2024-10-01'),
('LOTE-011', 8, 8, 1, 200.00, 200.00, '2023-11-01', '2024-11-01'),
('LOTE-012', 2, 1, 4, 600.00, 600.00, '2023-12-01', '2024-12-01'),
('LOTE-013', 9, 9, 7, 400.00, 400.00, '2024-01-01', '2024-09-01'),
('LOTE-014', 10, 10, 8, 800.00, 800.00, '2024-02-01', '2025-02-01'),
('LOTE-015', 11, 11, 2, 300.00, 300.00, '2024-03-01', '2025-03-01'),
('LOTE-016', 1, 12, 1, 1500.00, 1500.00, '2024-04-01', '2025-04-01'),
('LOTE-017', 2, 13, 3, 700.00, 700.00, '2024-05-01', '2025-05-01'),
('LOTE-018', 12, 14, 5, 500.00, 500.00, '2024-06-01', '2024-12-01'),
('LOTE-019', 13, 15, 6, 900.00, 900.00, '2024-07-01', '2025-07-01'),
('LOTE-020', 14, 16, 9, 1000.00, 1000.00, '2024-08-01', '2024-11-01');

-- 8. Inserindo Movimentações (20 registros de ENTRADA inicial)
-- Assumindo que os lotes acima geraram movimentações de entrada
INSERT INTO movimentacoes (id_lote, tipo_movimentacao, id_armazem_destino, quantidade_kg, saldo_anterior_kg, saldo_atual_kg, id_usuario) VALUES
(1, 'ENTRADA', 1, 1000.00, 0, 1000.00, 1),
(2, 'ENTRADA', 2, 500.00, 0, 500.00, 1),
(3, 'ENTRADA', 3, 800.00, 0, 800.00, 2),
(4, 'ENTRADA', 1, 600.00, 0, 600.00, 1),
(5, 'ENTRADA', 4, 1200.00, 0, 1200.00, 2),
(6, 'ENTRADA', 2, 400.00, 0, 400.00, 5),
(7, 'ENTRADA', 5, 2000.00, 0, 2000.00, 5),
(8, 'ENTRADA', 6, 300.00, 0, 300.00, 5),
(9, 'ENTRADA', 2, 1000.00, 0, 1000.00, 2),
(10, 'ENTRADA', 3, 500.00, 0, 500.00, 2),
(11, 'ENTRADA', 1, 200.00, 0, 200.00, 1),
(12, 'ENTRADA', 4, 600.00, 0, 600.00, 5),
(13, 'ENTRADA', 7, 400.00, 0, 400.00, 2),
(14, 'ENTRADA', 8, 800.00, 0, 800.00, 5),
(15, 'ENTRADA', 2, 300.00, 0, 300.00, 1),
(16, 'ENTRADA', 1, 1500.00, 0, 1500.00, 2),
(17, 'ENTRADA', 3, 700.00, 0, 700.00, 5),
(18, 'ENTRADA', 5, 500.00, 0, 500.00, 2),
(19, 'ENTRADA', 6, 900.00, 0, 900.00, 1),
(20, 'ENTRADA', 9, 1000.00, 0, 1000.00, 5);

-- 9. Inserindo Ordens de Expedição (20 registros)
INSERT INTO ordens_expedicao (numero_ordem, id_armazem, id_municipio, data_prevista_entrega, status, id_usuario_criacao) VALUES
('ORD-001', 1, 1, '2024-03-10', 'ENTREGUE', 1),
('ORD-002', 2, 2, '2024-03-11', 'ENTREGUE', 1),
('ORD-003', 3, 3, '2024-03-12', 'PENDENTE', 2),
('ORD-004', 4, 4, '2024-03-13', 'EM_TRANSITO', 2),
('ORD-005', 5, 5, '2024-03-14', 'PENDENTE', 5),
('ORD-006', 1, 6, '2024-03-15', 'CANCELADA', 1),
('ORD-007', 2, 2, '2024-03-16', 'ENTREGUE', 2),
('ORD-008', 3, 7, '2024-03-17', 'PENDENTE', 5),
('ORD-009', 4, 8, '2024-03-18', 'PENDENTE', 1),
('ORD-010', 5, 9, '2024-03-19', 'EM_TRANSITO', 5),
('ORD-011', 1, 10, '2024-03-20', 'PENDENTE', 2),
('ORD-012', 2, 11, '2024-03-21', 'ENTREGUE', 1),
('ORD-013', 3, 12, '2024-03-22', 'PENDENTE', 5),
('ORD-014', 4, 13, '2024-03-23', 'EM_TRANSITO', 2),
('ORD-015', 5, 14, '2024-03-24', 'PENDENTE', 1),
('ORD-016', 1, 15, '2024-03-25', 'PENDENTE', 5),
('ORD-017', 2, 16, '2024-03-26', 'ENTREGUE', 2),
('ORD-018', 3, 17, '2024-03-27', 'PENDENTE', 1),
('ORD-019', 4, 18, '2024-03-28', 'PENDENTE', 5),
('ORD-020', 5, 19, '2024-03-29', 'CANCELADA', 2);

-- 10. Inserindo Itens de Ordem (20 registros)
INSERT INTO itens_ordem (id_ordem, id_lote, quantidade_kg) VALUES
(1, 1, 100.00), (1, 4, 50.00),
(2, 2, 100.00), (2, 6, 20.00),
(3, 3, 200.00),
(4, 5, 150.00),
(5, 7, 300.00),
(6, 1, 100.00),
(7, 2, 50.00), (7, 9, 50.00),
(8, 10, 80.00),
(9, 12, 120.00),
(10, 7, 100.00),
(11, 11, 40.00),
(12, 6, 30.00), (12, 9, 30.00),
(13, 17, 100.00),
(14, 12, 60.00),
(15, 18, 90.00),
(16, 16, 200.00);

-- 11. Inserindo Entregas (20 registros - vinculadas a ordens entregues)
INSERT INTO entregas (id_ordem, id_agricultor, id_lote, quantidade_kg, id_usuario_entrega) VALUES
(1, 1, 1, 10.00, 3),
(1, 1, 4, 5.00, 3),
(1, 2, 1, 20.00, 3),
(1, 3, 1, 10.00, 3),
(2, 4, 2, 20.00, 6),
(2, 5, 2, 10.00, 6),
(2, 6, 6, 5.00, 6),
(7, 1, 2, 10.00, 9),
(7, 4, 9, 10.00, 9),
(12, 15, 6, 5.00, 3),
(12, 15, 9, 5.00, 3),
(17, 16, 2, 10.00, 6), -- Assumindo que a ordem 17 também foi entregue na lógica
(1, 7, 1, 15.00, 3),
(1, 8, 4, 10.00, 3),
(2, 9, 2, 15.00, 6),
(7, 10, 2, 10.00, 9),
(12, 11, 6, 5.00, 3),
(17, 12, 2, 10.00, 6),
(1, 13, 1, 20.00, 3),
(2, 14, 2, 15.00, 6);

-- =====================================================
-- SCRIPT DE CONSULTAS (DQL) - Mínimo 20 Selects
-- =====================================================

-- 1. Listar estoque total por espécie (com Join)
-- Objetivo: Saber quanto temos de cada semente somando todos os armazéns.
SELECT e.nome, SUM(l.quantidade_atual_kg) as total_kg 
FROM lotes l 
JOIN especies e ON l.id_especie = e.id_especie 
GROUP BY e.nome;

-- 2. Detalhar lotes armazenados com nome do fornecedor e armazém
-- Objetivo: Relatório operacional de localização de lotes.
SELECT l.numero_lote, e.nome as especie, f.razao_social as fornecedor, a.nome as armazem, l.quantidade_atual_kg
FROM lotes l
JOIN especies e ON l.id_especie = e.id_especie
JOIN fornecedores f ON l.id_fornecedor = f.id_fornecedor
JOIN armazens a ON l.id_armazem = a.id_armazem;

-- 3. Listar movimentações feitas por um usuário específico (Subselect)
-- Objetivo: Auditoria de ações do usuário 'João Silva'.
SELECT m.data_movimentacao, m.tipo_movimentacao, m.quantidade_kg
FROM movimentacoes m
WHERE m.id_usuario = (SELECT id_usuario FROM usuarios WHERE email = 'joao.admin@raiz.com');

-- 4. Agricultores que receberam entregas e qual espécie receberam (com join)
-- Objetivo: Rastreabilidade de quem recebeu o que.
SELECT a.nome as agricultor, e.nome as especie, ent.quantidade_kg, ent.data_entrega
FROM entregas ent
JOIN agricultores a ON ent.id_agricultor = a.id_agricultor
JOIN lotes l ON ent.id_lote = l.id_lote
JOIN especies e ON l.id_especie = e.id_especie;

-- 5. Ordens de expedição pendentes com nome do município (com join)
-- Objetivo: Gestão logística de ordens em aberto.
SELECT oe.numero_ordem, m.nome as municipio, oe.data_prevista_entrega
FROM ordens_expedicao oe
JOIN municipios m ON oe.id_municipio = m.id_municipio
WHERE oe.status = 'PENDENTE';

-- 6. Fornecedores que forneceram 'Milho Crioulo' (com join)
-- Objetivo: Identificar parceiros de uma cultura específica.
SELECT DISTINCT f.razao_social
FROM fornecedores f
JOIN lotes l ON f.id_fornecedor = l.id_fornecedor
JOIN especies e ON l.id_especie = e.id_especie
WHERE e.nome = 'Milho Crioulo';

-- 7. Percentual de ocupação de cada armazém (Subselect no cálculo)
-- Objetivo: Gestão de capacidade de armazenamento.
SELECT a.nome, 
       (SELECT SUM(quantidade_atual_kg) FROM lotes WHERE id_armazem = a.id_armazem) as ocupado,
       a.capacidade_kg,
       ((SELECT COALESCE(SUM(quantidade_atual_kg),0) FROM lotes WHERE id_armazem = a.id_armazem) / a.capacidade_kg * 100) as perc_ocupacao
FROM armazens a;

-- 8. Total distribuído por município (com join)
-- Objetivo: Mapa de distribuição de sementes.
SELECT m.nome, SUM(ent.quantidade_kg) as total_distribuido
FROM entregas ent
JOIN ordens_expedicao oe ON ent.id_ordem = oe.id_ordem
JOIN municipios m ON oe.id_municipio = m.id_municipio
GROUP BY m.nome;

-- 9. Lotes vencidos ou prestes a vencer (Subselect na data)
-- Objetivo: Controle de qualidade e perdas.
SELECT l.numero_lote, l.data_validade
FROM lotes l
WHERE l.data_validade < (SELECT DATE_ADD(CURDATE(), INTERVAL 30 DAY));

-- 10. Quantidade de ordens criadas por cada gestor (com join)
-- Objetivo: Produtividade da equipe administrativa.
SELECT u.nome, COUNT(oe.id_ordem) as qtd_ordens
FROM ordens_expedicao oe
JOIN usuarios u ON oe.id_usuario_criacao = u.id_usuario
GROUP BY u.nome;

-- 11. Agricultores que NUNCA receberam sementes (NOT IN Subselect)
-- Objetivo: Identificar público-alvo ainda não atendido.
SELECT a.nome, m.nome as cidade
FROM agricultores a
JOIN municipios m ON a.id_municipio = m.id_municipio
WHERE a.id_agricultor NOT IN (SELECT DISTINCT id_agricultor FROM entregas);

-- 12. Média de quantidade por entrega por espécie (com join)
-- Objetivo: Planejamento de kits de distribuição.
SELECT e.nome, AVG(ent.quantidade_kg) as media_entrega
FROM entregas ent
JOIN lotes l ON ent.id_lote = l.id_lote
JOIN especies e ON l.id_especie = e.id_especie
GROUP BY e.nome;

-- 13. Armazéns que possuem estoque de 'Feijão Macassar' (com join)
-- Objetivo: Localizar estoque específico para remanejamento.
SELECT DISTINCT a.nome
FROM armazens a
JOIN lotes l ON a.id_armazem = l.id_armazem
JOIN especies e ON l.id_especie = e.id_especie
WHERE e.nome = 'Feijão Macassar' AND l.quantidade_atual_kg > 0;

-- 14. Relatório de itens por ordem de expedição (com join)
-- Objetivo: Detalhar o romaneio de carga.
SELECT oe.numero_ordem, e.nome as produto, io.quantidade_kg
FROM itens_ordem io
JOIN ordens_expedicao oe ON io.id_ordem = oe.id_ordem
JOIN lotes l ON io.id_lote = l.id_lote
JOIN especies e ON l.id_especie = e.id_especie;

-- 15. Espécies com estoque zerado (LEFT JOIN e IS NULL) 
-- Objetivo: Identificar necessidade de compra.
SELECT e.nome
FROM especies e
LEFT JOIN lotes l ON e.id_especie = l.id_especie AND l.quantidade_atual_kg > 0
WHERE l.id_lote IS NULL;

-- 16. Total de beneficiários por tipo (com JOIN)
-- Objetivo: Perfil demográfico dos atendidos, garantindo que estão vinculados a municípios válidos.
SELECT a.tipo_produtor, COUNT(a.id_agricultor) as quantidade
FROM agricultores a
INNER JOIN municipios m ON a.id_municipio = m.id_municipio
WHERE a.ativo = TRUE
GROUP BY a.tipo_produtor;

-- 17. Valor total do estoque (com JOIN)
-- Objetivo: Valoração contábil do estoque, validando o vínculo com a tabela de espécies e armazéns.
SELECT SUM(l.quantidade_atual_kg * l.valor_unitario) as valor_total_estoque
FROM lotes l
INNER JOIN especies e ON l.id_especie = e.id_especie
INNER JOIN armazens ar ON l.id_armazem = ar.id_armazem
WHERE l.valor_unitario IS NOT NULL 
  AND l.status = 'DISPONIVEL';

-- 18. Movimentações de SAIDA por armazém (com join)
-- Objetivo: Identificar armazéns com maior fluxo de saída.
SELECT a.nome, COUNT(m.id_movimentacao) as qtd_saidas, SUM(m.quantidade_kg) as vol_saida
FROM movimentacoes m
JOIN armazens a ON m.id_armazem_origem = a.id_armazem
WHERE m.tipo_movimentacao = 'SAIDA'
GROUP BY a.nome;

-- 19. Agricultores de um estado específico (PE) via Município (com join)
-- Objetivo: Filtragem geográfica regional.
SELECT a.nome, m.nome as cidade
FROM agricultores a
JOIN municipios m ON a.id_municipio = m.id_municipio
WHERE m.estado = 'PE';

-- 20. Auditoria de Entregas: Quem entregou, quando e onde (com join)
-- Objetivo: Controle de campo.
SELECT u.nome as agente, a.nome as agricultor, ent.data_entrega, ent.latitude, ent.longitude
FROM entregas ent
JOIN usuarios u ON ent.id_usuario_entrega = u.id_usuario
JOIN agricultores a ON ent.id_agricultor = a.id_agricultor;

-- =====================================================
-- SCRIPT DE CRIAÇÃO DE VIEWS (Contendo 12 - DDL)
-- =====================================================

-- 1. View Estoque por Armazém
CREATE OR REPLACE VIEW vw_estoque_armazem AS
SELECT a.id_armazem, a.nome AS armazem, e.nome AS especie, SUM(l.quantidade_atual_kg) AS estoque_total
FROM armazens a
JOIN lotes l ON a.id_armazem = l.id_armazem
JOIN especies e ON l.id_especie = e.id_especie
WHERE l.status = 'DISPONIVEL'
GROUP BY a.id_armazem, e.id_especie;

-- 2. View Lotes Vencimento
CREATE OR REPLACE VIEW vw_lotes_vencimento AS
SELECT l.numero_lote, e.nome AS especie, l.data_validade, DATEDIFF(l.data_validade, CURDATE()) AS dias_restantes
FROM lotes l
JOIN especies e ON l.id_especie = e.id_especie
WHERE l.quantidade_atual_kg > 0;

-- 3. View Distribuição Município
CREATE OR REPLACE VIEW vw_distribuicao_municipio AS
SELECT m.nome, SUM(e.quantidade_kg) as total_kg
FROM entregas e
JOIN ordens_expedicao oe ON e.id_ordem = oe.id_ordem
JOIN municipios m ON oe.id_municipio = m.id_municipio
GROUP BY m.nome;

-- 4. View Performance Fornecedores
CREATE OR REPLACE VIEW vw_performance_fornecedores AS
SELECT f.razao_social, COUNT(l.id_lote) as qtd_lotes, SUM(l.quantidade_kg) as vol_fornecido
FROM fornecedores f
JOIN lotes l ON f.id_fornecedor = l.id_fornecedor
GROUP BY f.razao_social;

-- 5. View Ordens Pendentes
CREATE OR REPLACE VIEW vw_ordens_pendentes AS
SELECT oe.numero_ordem, m.nome as destino, oe.data_prevista_entrega
FROM ordens_expedicao oe
JOIN municipios m ON oe.id_municipio = m.id_municipio
WHERE oe.status = 'PENDENTE';

-- 6. View Rastreabilidade Lote
CREATE OR REPLACE VIEW vw_rastreabilidade_lote AS
SELECT l.numero_lote, COUNT(m.id_movimentacao) as qtd_mov, COUNT(e.id_entrega) as qtd_entregas
FROM lotes l
LEFT JOIN movimentacoes m ON l.id_lote = m.id_lote
LEFT JOIN entregas e ON l.id_lote = e.id_lote
GROUP BY l.numero_lote;

-- 7. View Dashboard KPIs
CREATE OR REPLACE VIEW vw_dashboard_kpis AS
SELECT 
    (SELECT COUNT(*) FROM agricultores) as total_agricultores,
    (SELECT SUM(quantidade_atual_kg) FROM lotes) as estoque_total,
    (SELECT COUNT(*) FROM ordens_expedicao WHERE status='PENDENTE') as ordens_abertas;

-- 8. View Agricultores por Município
CREATE OR REPLACE VIEW vw_agricultores_municipio AS
SELECT m.nome, COUNT(a.id_agricultor) as qtd_agricultores
FROM municipios m
LEFT JOIN agricultores a ON m.id_municipio = a.id_municipio
GROUP BY m.nome;

-- 9. View Movimentações Diárias
CREATE OR REPLACE VIEW vw_movimentacoes_diarias AS
SELECT DATE(data_movimentacao) as data, tipo_movimentacao, SUM(quantidade_kg) as total
FROM movimentacoes
GROUP BY DATE(data_movimentacao), tipo_movimentacao;

-- 10. View Entregas Periodo
CREATE OR REPLACE VIEW vw_entregas_periodo AS
SELECT YEAR(data_entrega) as ano, MONTH(data_entrega) as mes, SUM(quantidade_kg) as total
FROM entregas
GROUP BY YEAR(data_entrega), MONTH(data_entrega);

-- 11. View (NOVA) Usuários Ativos
CREATE OR REPLACE VIEW vw_usuarios_ativos AS
SELECT nome, email, perfil, ultimo_acesso
FROM usuarios
WHERE ativo = TRUE;

-- 12. View (NOVA) Espécies Mais Distribuídas
CREATE OR REPLACE VIEW vw_ranking_especies AS
SELECT e.nome, SUM(ent.quantidade_kg) as total_distribuido
FROM entregas ent
JOIN lotes l ON ent.id_lote = l.id_lote
JOIN especies e ON l.id_especie = e.id_especie
GROUP BY e.nome
ORDER BY total_distribuido DESC;

-- =====================================================
-- SCRIPT DE PROCEDURES E FUNCTIONS (SP/SQL)
-- =====================================================
DELIMITER $$

-- 1. FUNCTION: Calcular dias para vencimento
CREATE FUNCTION fn_dias_vencimento(p_id_lote INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_dias INT;
    SELECT DATEDIFF(data_validade, CURDATE()) INTO v_dias FROM lotes WHERE id_lote = p_id_lote;
    RETURN v_dias;
END $$

-- 2. FUNCTION: Verificar disponibilidade de estoque
CREATE FUNCTION fn_verifica_estoque(p_id_lote INT, p_qtd DECIMAL(10,2)) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_saldo DECIMAL(10,2);
    SELECT quantidade_atual_kg INTO v_saldo FROM lotes WHERE id_lote = p_id_lote;
    IF v_saldo >= p_qtd THEN RETURN TRUE; ELSE RETURN FALSE; END IF;
END $$

-- 3. FUNCTION: Obter nome do usuário
CREATE FUNCTION fn_get_nome_usuario(p_id INT) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE v_nome VARCHAR(100);
    SELECT nome INTO v_nome FROM usuarios WHERE id_usuario = p_id;
    RETURN v_nome;
END $$

-- 4. FUNCTION: Contar agricultores por cidade
CREATE FUNCTION fn_conta_agricultores(p_id_municipio INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM agricultores WHERE id_municipio = p_id_municipio;
    RETURN v_count;
END $$

-- 5. FUNCTION: Capacidade Restante Armazém
CREATE FUNCTION fn_capacidade_restante(p_arm INT) RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE v_cap DECIMAL(12,2);
    DECLARE v_uso DECIMAL(12,2);
    SELECT capacidade_kg INTO v_cap FROM armazens WHERE id_armazem = p_arm;
    SELECT COALESCE(SUM(quantidade_atual_kg),0) INTO v_uso FROM lotes WHERE id_armazem = p_arm;
    RETURN (v_cap - v_uso);
END $$

-- 6. FUNCTION: Formatar CPF
-- Objetivo: Retornar o CPF formatado (000.000.000-00) para exibição em relatórios.
CREATE FUNCTION fn_formatar_cpf(p_cpf VARCHAR(14)) RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    -- Remove caracteres não numéricos primeiro (se houver) e aplica máscara
    RETURN CONCAT(
        SUBSTRING(p_cpf, 1, 3), '.',
        SUBSTRING(p_cpf, 4, 3), '.',
        SUBSTRING(p_cpf, 7, 3), '-',
        SUBSTRING(p_cpf, 10, 2)
    );
END $$

-- 7. FUNCTION: Calcular Valor Total Estimado do Lote
-- Objetivo: Multiplicar a quantidade atual pelo valor unitário para saber quanto dinheiro está parado no lote.
CREATE FUNCTION fn_valor_total_lote(p_id_lote INT) RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(12,2);
    SELECT (quantidade_atual_kg * COALESCE(valor_unitario, 0)) INTO v_total 
    FROM lotes 
    WHERE id_lote = p_id_lote;
    RETURN v_total;
END $$

-- 8. FUNCTION: Obter Nome do Município por ID
-- Objetivo: Facilitar consultas rápidas onde só se tem o ID do município (ex: tabelas de log/auditoria).
CREATE FUNCTION fn_get_nome_municipio(p_id_municipio INT) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE v_nome VARCHAR(100);
    SELECT nome INTO v_nome FROM municipios WHERE id_municipio = p_id_municipio;
    RETURN v_nome;
END $$

-- 9. FUNCTION: Verificar se o Armazém está Lotado
-- Objetivo: Retorna TRUE se a ocupação for igual ou maior que a capacidade.
CREATE FUNCTION fn_armazem_lotado(p_id_armazem INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_capacidade DECIMAL(12,2);
    DECLARE v_ocupacao DECIMAL(12,2);
    
    SELECT capacidade_kg INTO v_capacidade FROM armazens WHERE id_armazem = p_id_armazem;
    SELECT COALESCE(SUM(quantidade_atual_kg), 0) INTO v_ocupacao FROM lotes WHERE id_armazem = p_id_armazem;
    
    IF v_ocupacao >= v_capacidade THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END $$

-- 10. FUNCTION: Calcular Progresso da Ordem de Expedição (%)
-- Objetivo: Retorna a porcentagem de itens entregues em relação ao total solicitado na ordem.
CREATE FUNCTION fn_progresso_ordem(p_id_ordem INT) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_total_kg DECIMAL(10,2);
    DECLARE v_entregue_kg DECIMAL(10,2);
    
    -- Total solicitado na ordem
    SELECT SUM(quantidade_kg) INTO v_total_kg FROM itens_ordem WHERE id_ordem = p_id_ordem;
    
    -- Total já entregue (via tabela entregas)
    SELECT COALESCE(SUM(quantidade_kg), 0) INTO v_entregue_kg FROM entregas WHERE id_ordem = p_id_ordem;
    
    IF v_total_kg IS NULL OR v_total_kg = 0 THEN
        RETURN 0.00;
    ELSE
        RETURN (v_entregue_kg / v_total_kg) * 100;
    END IF;
END $$

-- 11. FUNCTION: Obter Endereço Completo do Agricultor
-- Objetivo: Concatenar rua, cidade e estado para etiquetas de entrega.
CREATE FUNCTION fn_endereco_completo_agricultor(p_id_agricultor INT) RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE v_endereco_completo VARCHAR(255);
    
    SELECT CONCAT(a.endereco, ' - ', m.nome, '/', m.estado) INTO v_endereco_completo
    FROM agricultores a
    JOIN municipios m ON a.id_municipio = m.id_municipio
    WHERE a.id_agricultor = p_id_agricultor;
    
    RETURN v_endereco_completo;
END $$

-- 12. FUNCTION: Contar Lotes Vencidos por Fornecedor
-- Objetivo: Métrica de qualidade para avaliar fornecedores.
CREATE FUNCTION fn_lotes_vencidos_fornecedor(p_id_fornecedor INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count 
    FROM lotes 
    WHERE id_fornecedor = p_id_fornecedor 
      AND data_validade < CURDATE()
      AND quantidade_atual_kg > 0;
    RETURN v_count;
END $$

-- 13. FUNCTION: Calcular Média de Distribuição por Município
-- Objetivo: Retorna a média de quilos entregues por agricultor em determinado município.
CREATE FUNCTION fn_media_kg_por_agricultor_municipio(p_id_municipio INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_media DECIMAL(10,2);
    
    SELECT AVG(total_kg_agricultor) INTO v_media
    FROM (
        SELECT e.id_agricultor, SUM(e.quantidade_kg) as total_kg_agricultor
        FROM entregas e
        JOIN ordens_expedicao oe ON e.id_ordem = oe.id_ordem
        WHERE oe.id_municipio = p_id_municipio
        GROUP BY e.id_agricultor
    ) as subquery_media;
    
    RETURN COALESCE(v_media, 0);
END $$

-- 14. FUNCTION: Verificar se Usuário é Gestor
-- Objetivo: Verificação rápida de permissão para uso em triggers ou procedures.
CREATE FUNCTION fn_is_gestor(p_id_usuario INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_perfil VARCHAR(20);
    SELECT perfil INTO v_perfil FROM usuarios WHERE id_usuario = p_id_usuario;
    
    IF v_perfil = 'GESTOR' THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END $$


-- Criação das procedures

-- 1. PROCEDURE: Registrar Login de Usuário
-- Objetivo: Atualizar o campo 'ultimo_acesso' sempre que um usuário logar no sistema, para monitoramento de segurança e atividade.
CREATE PROCEDURE sp_registrar_login(IN p_email VARCHAR(100))
BEGIN
    UPDATE usuarios 
    SET ultimo_acesso = CURRENT_TIMESTAMP 
    WHERE email = p_email AND ativo = TRUE;
END $$

-- 2. PROCEDURE: Cadastrar Nova Espécie
-- Objetivo: Inserir uma nova semente no sistema de forma simplificada, definindo os campos obrigatórios.
CREATE PROCEDURE sp_cadastrar_especie(
    IN p_nome VARCHAR(100), 
    IN p_nome_cientifico VARCHAR(150), 
    IN p_categoria VARCHAR(50), 
    IN p_validade_dias INT
)
BEGIN
    INSERT INTO especies (nome, nome_cientifico, categoria, periodo_validade_dias, ativo)
    VALUES (p_nome, p_nome_cientifico, p_categoria, p_validade_dias, TRUE);
END $$

-- 3. PROCEDURE: Processar Vencimento de Lotes (Rotina Automática)
-- Objetivo: Atualizar o status de todos os lotes cuja data de validade já expirou para 'VENCIDO'. Ideal para ser rodado diariamente por um cron job/evento.
CREATE PROCEDURE sp_processar_vencimento_lotes()
BEGIN
    UPDATE lotes 
    SET status = 'VENCIDO' 
    WHERE data_validade < CURDATE() 
      AND status IN ('DISPONIVEL', 'EM_TRANSITO')
      AND quantidade_atual_kg > 0;
END $$

-- 4. PROCEDURE: Realizar Ajuste de Estoque (Inventário)
-- Objetivo: Corrigir manualmente a quantidade de um lote (perda, roubo ou erro de contagem) e registrar isso na tabela de movimentações como 'AJUSTE'.
CREATE PROCEDURE sp_realizar_ajuste_estoque(
    IN p_id_lote INT, 
    IN p_nova_quantidade DECIMAL(10,2), 
    IN p_id_usuario INT, 
    IN p_motivo VARCHAR(200)
)
BEGIN
    DECLARE v_qtd_anterior DECIMAL(10,2);
    DECLARE v_diferenca DECIMAL(10,2);
    DECLARE v_id_armazem INT;

    -- Busca dados atuais do lote
    SELECT quantidade_atual_kg, id_armazem INTO v_qtd_anterior, v_id_armazem 
    FROM lotes WHERE id_lote = p_id_lote;

    -- Calcula a diferença (pode ser negativa ou positiva)
    SET v_diferenca = p_nova_quantidade - v_qtd_anterior;

    -- Atualiza o lote
    UPDATE lotes 
    SET quantidade_atual_kg = p_nova_quantidade 
    WHERE id_lote = p_id_lote;

    -- Registra na movimentação (AJUSTE)
    INSERT INTO movimentacoes (
        id_lote, tipo_movimentacao, id_armazem_origem, id_armazem_destino, 
        quantidade_kg, saldo_anterior_kg, saldo_atual_kg, id_usuario, motivo
    ) VALUES (
        p_id_lote, 'AJUSTE', v_id_armazem, v_id_armazem, 
        ABS(v_diferenca), v_qtd_anterior, p_nova_quantidade, p_id_usuario, p_motivo
    );
END $$

-- 5. PROCEDURE: Transferir Lote Completo entre Armazéns
-- Objetivo: Mover fisicamente um lote inteiro de um armazém para outro, atualizando o registro e gerando histórico de transferência.
CREATE PROCEDURE sp_transferir_lote_completo(
    IN p_id_lote INT, 
    IN p_id_armazem_destino INT, 
    IN p_id_usuario INT
)
BEGIN
    DECLARE v_id_armazem_origem INT;
    DECLARE v_qtd_atual DECIMAL(10,2);

    -- Verifica dados atuais
    SELECT id_armazem, quantidade_atual_kg INTO v_id_armazem_origem, v_qtd_atual
    FROM lotes WHERE id_lote = p_id_lote;

    -- Se origem for diferente do destino, executa
    IF v_id_armazem_origem != p_id_armazem_destino THEN
        
        -- Atualiza a localização do lote
        UPDATE lotes 
        SET id_armazem = p_id_armazem_destino 
        WHERE id_lote = p_id_lote;

        -- Registra a movimentação
        INSERT INTO movimentacoes (
            id_lote, tipo_movimentacao, id_armazem_origem, id_armazem_destino, 
            quantidade_kg, saldo_anterior_kg, saldo_atual_kg, id_usuario, motivo
        ) VALUES (
            p_id_lote, 'TRANSFERENCIA', v_id_armazem_origem, p_id_armazem_destino, 
            v_qtd_atual, v_qtd_atual, v_qtd_atual, p_id_usuario, 'Transferência total de lote'
        );
    END IF;
END $$

-- 6. PROCEDURE: Cadastrar Usuário
CREATE PROCEDURE sp_cadastrar_usuario(
    IN p_nome VARCHAR(100), IN p_email VARCHAR(100), IN p_senha VARCHAR(255), 
    IN p_cpf VARCHAR(14), IN p_perfil VARCHAR(20)
)
BEGIN
    INSERT INTO usuarios (nome, email, senha_hash, cpf, perfil) 
    VALUES (p_nome, p_email, p_senha, p_cpf, p_perfil);
END $$

-- 7. PROCEDURE: Atualizar Senha
CREATE PROCEDURE sp_atualizar_senha(IN p_id INT, IN p_nova_senha VARCHAR(255))
BEGIN
    UPDATE usuarios SET senha_hash = p_nova_senha WHERE id_usuario = p_id;
END $$

-- 8. PROCEDURE: Criar Lote
CREATE PROCEDURE sp_criar_lote(
    IN p_numero VARCHAR(50), IN p_especie INT, IN p_forn INT, 
    IN p_arm INT, IN p_qtd DECIMAL(10,2), IN p_val DATE
)
BEGIN
    INSERT INTO lotes (numero_lote, id_especie, id_fornecedor, id_armazem, quantidade_kg, quantidade_atual_kg, data_fabricacao, data_validade)
    VALUES (p_numero, p_especie, p_forn, p_arm, p_qtd, p_qtd, CURDATE(), p_val);
END $$

-- 9. PROCEDURE: Registrar Movimentação (Complexa com Update de Saldo)
CREATE PROCEDURE sp_registrar_movimentacao(
    IN p_lote INT, IN p_tipo VARCHAR(20), IN p_qtd DECIMAL(10,2), 
    IN p_origem INT, IN p_destino INT, IN p_user INT
)
BEGIN
    DECLARE v_saldo_anterior DECIMAL(10,2);
    DECLARE v_saldo_novo DECIMAL(10,2);
    
    SELECT quantidade_atual_kg INTO v_saldo_anterior FROM lotes WHERE id_lote = p_lote;
    
    IF p_tipo = 'ENTRADA' THEN
        SET v_saldo_novo = v_saldo_anterior + p_qtd;
    ELSEIF p_tipo = 'SAIDA' THEN
        SET v_saldo_novo = v_saldo_anterior - p_qtd;
    ELSE
        SET v_saldo_novo = v_saldo_anterior; -- Transferencia apenas muda local na logica completa
    END IF;
    
    UPDATE lotes SET quantidade_atual_kg = v_saldo_novo WHERE id_lote = p_lote;
    
    INSERT INTO movimentacoes (id_lote, tipo_movimentacao, id_armazem_origem, id_armazem_destino, quantidade_kg, saldo_anterior_kg, saldo_atual_kg, id_usuario)
    VALUES (p_lote, p_tipo, p_origem, p_destino, p_qtd, v_saldo_anterior, v_saldo_novo, p_user);
END $$

-- 10. PROCEDURE: Criar Ordem Expedição
CREATE PROCEDURE sp_criar_ordem(IN p_num VARCHAR(50), IN p_arm INT, IN p_mun INT, IN p_user INT)
BEGIN
    INSERT INTO ordens_expedicao (numero_ordem, id_armazem, id_municipio, data_prevista_entrega, id_usuario_criacao)
    VALUES (p_num, p_arm, p_mun, DATE_ADD(CURDATE(), INTERVAL 7 DAY), p_user);
END $$

-- 11. PROCEDURE: Adicionar Item na Ordem
CREATE PROCEDURE sp_add_item_ordem(IN p_ordem INT, IN p_lote INT, IN p_qtd DECIMAL(10,2))
BEGIN
    INSERT INTO itens_ordem (id_ordem, id_lote, quantidade_kg) VALUES (p_ordem, p_lote, p_qtd);
END $$

-- 12. PROCEDURE: Registrar Entrega
CREATE PROCEDURE sp_registrar_entrega(IN p_ordem INT, IN p_agri INT, IN p_lote INT, IN p_qtd DECIMAL(10,2), IN p_user INT)
BEGIN
    INSERT INTO entregas (id_ordem, id_agricultor, id_lote, quantidade_kg, id_usuario_entrega)
    VALUES (p_ordem, p_agri, p_lote, p_qtd, p_user);
END $$

-- 13. PROCEDURE: Desativar Agricultor
CREATE PROCEDURE sp_desativar_agricultor(IN p_id INT)
BEGIN
    UPDATE agricultores SET ativo = FALSE WHERE id_agricultor = p_id;
END $$

-- 14. PROCEDURE: Atualizar Status Ordem
CREATE PROCEDURE sp_atualizar_status_ordem(IN p_id INT, IN p_status VARCHAR(20))
BEGIN
    UPDATE ordens_expedicao SET status = p_status WHERE id_ordem = p_id;
END $$



DELIMITER ;

-- =====================================================
-- SCRIPT DE EXECUÇÃO DAS PROCEDURES E FUNCTIONS
-- =====================================================
-- Testando Function
SELECT fn_dias_vencimento(1) AS dias_vencer_lote_1;
SELECT fn_get_nome_usuario(1) AS nome_admin;

-- Testando Procedures
CALL sp_cadastrar_usuario('Teste Procedure', 'teste@teste.com', '123', '00000000099', 'OPERADOR');
CALL sp_criar_lote('LOTE-TEST-SP', 1, 1, 1, 100.00, '2025-12-31');
-- Nota: Ao testar sp_registrar_movimentacao, certifique-se que o lote existe
CALL sp_registrar_movimentacao(1, 'SAIDA', 10.00, 1, NULL, 1);
CALL sp_criar_ordem('ORD-TESTE-01', 1, 1, 1);
CALL sp_atualizar_status_ordem(1, 'EM_TRANSITO');


-- =====================================================
-- SCRIPT DE TRIGGERS (Contendo 12)
-- =====================================================
DELIMITER $$

-- 1. Trigger Audit Insert Usuario
CREATE TRIGGER trg_audit_user_insert AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabela, operacao, id_registro, dados_novos)
    VALUES ('usuarios', 'INSERT', NEW.id_usuario, JSON_OBJECT('nome', NEW.nome));
END $$

-- 2. Trigger Audit Update Usuario
CREATE TRIGGER trg_audit_user_update AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabela, operacao, id_registro, dados_antigos, dados_novos)
    VALUES ('usuarios', 'UPDATE', OLD.id_usuario, JSON_OBJECT('nome', OLD.nome), JSON_OBJECT('nome', NEW.nome));
END $$

-- 3. Trigger Audit Delete Usuario
CREATE TRIGGER trg_audit_user_delete AFTER DELETE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabela, operacao, id_registro, dados_antigos)
    VALUES ('usuarios', 'DELETE', OLD.id_usuario, JSON_OBJECT('nome', OLD.nome));
END $$

-- 4. Trigger Atualizar Status Lote ao Zerar
CREATE TRIGGER trg_lote_esgotado BEFORE UPDATE ON lotes
FOR EACH ROW
BEGIN
    IF NEW.quantidade_atual_kg <= 0 THEN
        SET NEW.status = 'ESGOTADO';
    END IF;
END $$

-- 5. Trigger Validar Data Validade Lote
CREATE TRIGGER trg_valida_lote_insert BEFORE INSERT ON lotes
FOR EACH ROW
BEGIN
    IF NEW.data_validade <= CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Lote já vencido não pode ser cadastrado.';
    END IF;
END $$

-- 6. Trigger Log Movimentacao Estoque
CREATE TRIGGER trg_log_movimentacao AFTER INSERT ON movimentacoes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabela, operacao, id_registro, dados_novos)
    VALUES ('movimentacoes', 'INSERT', NEW.id_movimentacao, JSON_OBJECT('lote', NEW.id_lote, 'qtd', NEW.quantidade_kg));
END $$

-- 7. Trigger Bloquear Entrega se Ordem Cancelada
CREATE TRIGGER trg_bloqueia_entrega BEFORE INSERT ON entregas
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    SELECT status INTO v_status FROM ordens_expedicao WHERE id_ordem = NEW.id_ordem;
    IF v_status = 'CANCELADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Não pode entregar itens de ordem cancelada.';
    END IF;
END $$

-- 8. Trigger Atualizar Data Expedição
CREATE TRIGGER trg_atualiza_expedicao BEFORE UPDATE ON ordens_expedicao
FOR EACH ROW
BEGIN
    IF NEW.status = 'EM_TRANSITO' AND OLD.status != 'EM_TRANSITO' THEN
        SET NEW.data_expedicao = CURRENT_TIMESTAMP;
    END IF;
END $$

-- 9. Trigger Impedir Delete Fornecedor com Lotes
CREATE TRIGGER trg_check_fornecedor_del BEFORE DELETE ON fornecedores
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM lotes WHERE id_fornecedor = OLD.id_fornecedor;
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Fornecedor possui lotes vinculados.';
    END IF;
END $$

-- 10. Trigger Impedir Delete Armazem com Estoque
CREATE TRIGGER trg_check_armazem_del BEFORE DELETE ON armazens
FOR EACH ROW
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count FROM lotes WHERE id_armazem = OLD.id_armazem AND quantidade_atual_kg > 0;
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Armazém possui estoque positivo.';
    END IF;
END $$

-- 11. Trigger Preencher Data Cadastro Agricultor (caso nulo)
CREATE TRIGGER trg_data_agric BEFORE INSERT ON agricultores
FOR EACH ROW
BEGIN
    IF NEW.data_cadastro IS NULL THEN
        SET NEW.data_cadastro = CURRENT_TIMESTAMP;
    END IF;
END $$

-- 12. Trigger Audit Insert Entrega
CREATE TRIGGER trg_audit_entrega AFTER INSERT ON entregas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabela, operacao, id_registro, id_usuario, dados_novos)
    VALUES ('entregas', 'INSERT', NEW.id_entrega, NEW.id_usuario_entrega, JSON_OBJECT('ordem', NEW.id_ordem));
END $$

DELIMITER ;

-- =====================================================
-- SCRIPT DE TESTE DE TRIGGERS
-- =====================================================
-- Teste Trigger 1 (Audit Insert Usuario)
INSERT INTO usuarios (nome, email, senha_hash, cpf, perfil) VALUES ('User Trigger Test', 'trig@test.com', '123', '99999999999', 'AGENTE');
SELECT * FROM auditoria WHERE tabela = 'usuarios' ORDER BY id_auditoria DESC LIMIT 1;

-- Teste Trigger 2 (Audit Update Usuario)
UPDATE usuarios SET nome = 'User Trigger Modified' WHERE email = 'trig@test.com';
SELECT * FROM auditoria WHERE tabela = 'usuarios' ORDER BY id_auditoria DESC LIMIT 1;

-- Teste Trigger 4 (Status Esgotado) - Requer criação de lote temporário para não quebrar dados reais
INSERT INTO lotes (numero_lote, id_especie, id_fornecedor, id_armazem, quantidade_kg, quantidade_atual_kg, data_fabricacao, data_validade)
VALUES ('LOTE-TRIG-04', 1, 1, 1, 10.00, 10.00, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 YEAR));
UPDATE lotes SET quantidade_atual_kg = 0 WHERE numero_lote = 'LOTE-TRIG-04';
SELECT status FROM lotes WHERE numero_lote = 'LOTE-TRIG-04'; -- Deve ser 'ESGOTADO'

-- Teste Trigger 8 (Data Expedição)
INSERT INTO ordens_expedicao (numero_ordem, id_armazem, id_municipio, data_prevista_entrega, status, id_usuario_criacao)
VALUES ('ORD-TRIG-08', 1, 1, CURDATE(), 'PENDENTE', 1);
UPDATE ordens_expedicao SET status = 'EM_TRANSITO' WHERE numero_ordem = 'ORD-TRIG-08';
SELECT data_expedicao FROM ordens_expedicao WHERE numero_ordem = 'ORD-TRIG-08'; -- Não deve ser NULL