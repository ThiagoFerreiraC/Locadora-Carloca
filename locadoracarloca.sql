CREATE DATABASE `locadora_carloca` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

-- locadora_carloca.categoria_veiculo definition

-- locadora_carloca.categoria definition

CREATE TABLE `categoria` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `DESCRICAO` varchar(255) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- locadora_carloca.cliente definition

-- locadora_carloca.cliente definition

CREATE TABLE `cliente` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `NOME` varchar(255) NOT NULL,
  `SOBRENOME` varchar(255) NOT NULL,
  `TELEFONE` varchar(13) NOT NULL,
  `CPF` varchar(11) NOT NULL,
  `CNH` varchar(10) NOT NULL,
  `STATUS` enum('BLOQUEADO','LIBERADO') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'LIBERADO',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `cliente_un` (`CPF`,`CNH`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- locadora_carloca.filial definition

CREATE TABLE `filial` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `CEP` varchar(8) NOT NULL,
  `CIDADE` varchar(255) NOT NULL,
  `ESTADO` varchar(2) NOT NULL,
  `BAIRRO` varchar(255) NOT NULL,
  `LOGRADOURO` varchar(255) NOT NULL,
  `NUMERO` int NOT NULL,
  `COMPLEMENTO` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- locadora_carloca.montadora definition

CREATE TABLE `montadora` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `NOME` varchar(100) NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `montadora_un` (`NOME`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- locadora_carloca.veiculo definition

CREATE TABLE `veiculo` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `PLACA` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ID_CATEGORIA` int NOT NULL,
  `ID_MONTADORA` int NOT NULL,
  `VERSAO` varchar(100) NOT NULL,
  `ANO` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `COR` enum('PRETO','PRATA','BRANCO') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `QUILOMETRAGEM` int NOT NULL,
  `STATUS` enum('BLOQUEADO','LIBERADO') NOT NULL DEFAULT 'LIBERADO',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `veiculo_un` (`PLACA`),
  KEY `veiculo_FK` (`ID_CATEGORIA`),
  KEY `veiculo_FK_1` (`ID_MONTADORA`),
  CONSTRAINT `veiculo_FK` FOREIGN KEY (`ID_CATEGORIA`) REFERENCES `categoria` (`ID`),
  CONSTRAINT `veiculo_FK_1` FOREIGN KEY (`ID_MONTADORA`) REFERENCES `montadora` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- locadora_carloca.filial_veiculo definition

CREATE TABLE `filial_veiculo` (
  `ID_FILIAL` int NOT NULL,
  `ID_VEICULO` int NOT NULL,
  UNIQUE KEY `filial_veiculo_un` (`ID_VEICULO`),
  KEY `FILIAL_VEICULO_FK` (`ID_FILIAL`),
  CONSTRAINT `FILIAL_VEICULO_FK` FOREIGN KEY (`ID_FILIAL`) REFERENCES `filial` (`ID`),
  CONSTRAINT `FILIAL_VEICULO_FK_1` FOREIGN KEY (`ID_VEICULO`) REFERENCES `veiculo` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- locadora_carloca.reserva definition

CREATE TABLE `reserva` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `MODALIDADE` enum('DIARIA') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'DIARIA',
  `ID_CLIENTE` int NOT NULL,
  `FILIAL_RESERVA` int NOT NULL,
  `ID_VEICULO` int NOT NULL,
  `FILIAL_DESTINO` int NOT NULL,
  `DATA_INICIAL` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DATA_FINAL` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `STATUS` enum('EM CURSO','CONCLUIDA') NOT NULL DEFAULT 'EM CURSO',
  `QUILOMETRAGEM_RODADA` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `reserva_FK` (`ID_CLIENTE`),
  KEY `reserva_FK_1` (`ID_VEICULO`),
  KEY `reserva_FK_2` (`FILIAL_DESTINO`),
  KEY `reserva_FK_3` (`FILIAL_RESERVA`),
  CONSTRAINT `reserva_FK` FOREIGN KEY (`ID_CLIENTE`) REFERENCES `cliente` (`ID`),
  CONSTRAINT `reserva_FK_1` FOREIGN KEY (`ID_VEICULO`) REFERENCES `veiculo` (`ID`),
  CONSTRAINT `reserva_FK_2` FOREIGN KEY (`FILIAL_DESTINO`) REFERENCES `filial` (`ID`),
  CONSTRAINT `reserva_FK_3` FOREIGN KEY (`FILIAL_RESERVA`) REFERENCES `filial` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE DEFINER=`root`@`localhost` TRIGGER `PREVENIR_LOCACAO` BEFORE INSERT ON `reserva` FOR EACH ROW BEGIN
	if exists (select 1 from locadora_carloca.cliente c where new.ID_CLIENTE = ID and c.STATUS = 'BLOQUEADO') then 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente já está alugando um veículo';
    END IF;
   if exists (select 1 from locadora_carloca.veiculo v where new.ID_VEICULO = ID and v.STATUS = 'BLOQUEADO') then 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Veiculo indisponível';
    END IF;
END;

CREATE DEFINER=`root`@`localhost` TRIGGER `BLOQUEAR_STATUS` AFTER INSERT ON `reserva` FOR EACH ROW begin 
	update locadora_carloca.veiculo 
	set STATUS = 'BLOQUEADO'
	where ID = new.ID_VEICULO;

	update locadora_carloca.cliente 
	set STATUS = 'BLOQUEADO'
	where ID = new.ID_CLIENTE;
end;

CREATE DEFINER=`root`@`localhost` TRIGGER `ATUALIZAR_QUILOMETRAGEM` AFTER UPDATE ON `reserva` FOR EACH ROW begin 
	update locadora_carloca.veiculo 
	set QUILOMETRAGEM = QUILOMETRAGEM + new.QUILOMETRAGEM_RODADA
	where ID = new.ID_VEICULO;
end;

CREATE DEFINER=`root`@`localhost` TRIGGER `LIBERAR_STATUS` AFTER UPDATE ON `reserva` FOR EACH ROW begin 
	if new.STATUS = 'CONCLUIDA' THEN
	update locadora_carloca.veiculo 
	set STATUS = 'LIBERADO'
	where ID = new.ID_VEICULO;
	update locadora_carloca.cliente  
	set STATUS = 'LIBERADO'
	where ID = new.ID_CLIENTE;
end if;
end;
