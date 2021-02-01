DROP database IF EXISTS project;
CREATE DATABASE IF NOT EXISTS `project` DEFAULT CHARACTER SET = 'utf8' DEFAULT COLLATE 'utf8_general_ci';
-- -----------------------------------------------------
-- Schema project
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `project` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `project` ;

-- -----------------------------------------------------
-- Table `project`.`product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `project`.`product` (
  `Product_ID` INT NOT NULL,
  `Product_Name` VARCHAR(40) NOT NULL,
  `Product_Description` VARCHAR(100) NULL,
  `Product_Price` FLOAT NOT NULL,
  `Product_Color` VARCHAR(45) NULL,
  `Product_Size` VARCHAR(3) NULL,
  `Product_Rating`DOUBLE NULL,
  PRIMARY KEY (`Product_ID`));

-- -----------------------------------------------------
-- Table `project`.`costs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `project`.`costs` (
  `costs_id` INT NOT NULL AUTO_INCREMENT,
  `Product_id` INT NULL,
  `Material` VARCHAR(15) NULL,
  `Material_price` FLOAT NULL,
  `labor_price` FLOAT NULL,
  PRIMARY KEY (`costs_id`),
  INDEX `Product_id_idx` (`Product_id` ASC) VISIBLE,
  CONSTRAINT `Product_id`
    FOREIGN KEY (`Product_id`)
    REFERENCES `project`.`product` (`Product_ID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);

-- -----------------------------------------------------
-- Table `project`.`location`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `project`.`location` (
  `Location_ID` INT NOT NULL,
  `Street_Address` VARCHAR(45) NOT NULL,
  `ZIP_Code` VARCHAR(8) NOT NULL,
  `City` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Location_ID`));

-- -----------------------------------------------------
-- Table `project`.`client`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `project`.`client` (
  `Client_ID` INT NOT NULL,
  `Client_Name` VARCHAR(45) NOT NULL,
  `Client_Email` VARCHAR(55) NOT NULL,
  `Client_Phone` VARCHAR(15) NULL,
  `Location_ID` INT NULL,
  `Client_NIF` VARCHAR(15) NULL,
  `Client_Age` TINYINT,
  `Client_Category` VARCHAR(20),
  PRIMARY KEY (`Client_ID`),
  INDEX `Location_ID` (`Location_ID` ASC) INVISIBLE,
  CONSTRAINT `Location_ID`
    FOREIGN KEY (`Location_ID`)
    REFERENCES `project`.`location` (`Location_ID`)
    ON UPDATE CASCADE);

-- -----------------------------------------------------
-- Table `project`.`company`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `project`.`company` (
  `Company_Name` VARCHAR(15) NOT NULL,
  `Company_Address` VARCHAR(45) NULL,
  `Company_ZIP_Code` VARCHAR(8) NULL,
  `Company_Website` VARCHAR(45) NULL,
  `Company_Email` VARCHAR(45) NULL,
  PRIMARY KEY (`Company_Name`));

-- -----------------------------------------------------
-- Table `project`.`purchase`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `project`.`purchase` (
  `Purchase_ID` INT NOT NULL,
  `Client_ID` INT NULL,
  `Date_Purchase` DATE NULL,
  `Purchase_Status` VARCHAR(45) NULL,
  `Purchase_Comments` VARCHAR(100) NULL,
  `Invoice_number`INT NULL,
  PRIMARY KEY (`Purchase_ID`),
  INDEX `fk_purchase_1` (`Client_ID` ASC) INVISIBLE,
  CONSTRAINT `fk_purchase_1`
    FOREIGN KEY (`Client_ID`)
    REFERENCES `project`.`client` (`Client_ID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);
    
    -- -----------------------------------------------------
-- Table `project`.`payment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `project`.`payment` (
  `Payment_ID` INT NOT NULL,
  `Purchase_ID` INT NULL,
  `Payment_Data` DATE NULL,
  `Total_Value` FLOAT NULL,
  `Payment_Type` VARCHAR(45) NULL,
  PRIMARY KEY (`Payment_ID`),
  INDEX `fk_payment_1` (`Purchase_ID` ASC) INVISIBLE,
  CONSTRAINT `fk_payment_1`
    FOREIGN KEY (`Purchase_ID`)
    REFERENCES `project`.`purchase` (`Purchase_ID`)
    ON UPDATE CASCADE);


-- -----------------------------------------------------
-- Table `project`.`item_purchase`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `project`.`item_purchase` (
  `Purchase_ID` INT NOT NULL,
  `Product_ID` INT NOT NULL,
  `Number_Items` TINYINT NULL,
  `Discount` FLOAT NULL CHECK (0<=`Discount` AND `Discount`<1),
  PRIMARY KEY (`Purchase_ID`, `Product_ID`),
  INDEX `fk_item_1` (`Purchase_ID` ASC) VISIBLE,
  INDEX `fk_item_2` (`Product_ID` ASC) VISIBLE,
  CONSTRAINT `fk_item_1`
    FOREIGN KEY (`Purchase_ID`)
    REFERENCES `project`.`purchase` (`Purchase_ID`)
    ON UPDATE CASCADE,
  CONSTRAINT `fk_item_2`
    FOREIGN KEY (`Product_ID`)
    REFERENCES `project`.`product` (`Product_ID`)
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table `project`.`stock`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `project`.`stock` (
  `Stock_ID` INT NOT NULL,
  `Product_ID` INT NULL,
  `Stock_Quantity` SMALLINT NULL CHECK (0<=`Stock_Quantity`),
  PRIMARY KEY (`Stock_ID`),
  INDEX `fk_stock_1` (`Stock_ID` ASC) VISIBLE,
  INDEX `fk_stock_1_idx` (`Product_ID` ASC) VISIBLE,
  CONSTRAINT `fk_stock_1`
    FOREIGN KEY (`Product_ID`)
    REFERENCES `project`.`product` (`Product_ID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);
    
-- -----------------------------------------------------
-- Table `old_customers`
-- -----------------------------------------------------
create table `old_customers`(
`customer_name` VARCHAR(45),
`Age` INT,
`Email` VARCHAR(55),
`Categories` VARCHAR(20),
PRIMARY KEY (`customer_name`,`age`));

select * from old_customers;


/* LITERAL C */
/*trigger 1 (Stock_Quantity_after_purchase_Update): updates the stock of products after the customer completes an order*/
delimiter $$
CREATE TRIGGER  Stock_Quantity_after_purchase_Update
AFTER INSERT  /*action will be done after insert (after the purchase is made)*/
   ON item_purchase 
   FOR EACH ROW
BEGIN
UPDATE stock
SET stock.stock_quantity =  stock.stock_quantity - New.Number_Items 
WHERE stock.Product_ID = New.Product_ID;
END $$
Delimiter ;


/*trigger (2):inserts a row in a “log” table if the price of a product is updated*/
create table data_log(
id integer unsigned auto_increment Primary Key,
action_time DATETIME,
usr Varchar(50),   
msg varchar(50),
previous_value integer,
new_value integer
);

delimiter $$ 
create trigger on_product_price_update
After update         /*action will be done after update*/
on product
for each row   
Begin   
insert into data_log (action_time,USR,MSG,previous_value,new_value)
values
(now(), user(), concat('price_update on product ', NEW.Product_ID) ,old.product_price, New.product_price);
End $$
delimiter ;

insert into `location` (`Location_ID`,`Street_Address`,`City` ,`Zip_Code`) values
(1,'Rua António Damásio nº14','Lisboa','1150-633'),
(2,'Rua Carlos da Maia nº22','Lisboa','1150-496'),
(3,'Rua das Flores nº7','Porto','3466-553'),
(4,'Rua do azar nº98' ,'Aveiro','3810-357'),
(5,'Rua do dinheiro nº3','Coimbra','1234-543'),
(6,'Rua da Maria Rita nº156','Faro','8000-463'),
(7,'Travessa da rapaziada nº87','Lisboa','1150-274'),
(8,'Rua Almeida e Sousa nº1' ,'Lisboa','1150-583'),
(9,'Avenida 25 de abril nº2','Bragança','5300-742'),
(10,'Rua do povo nº16','Guarda','5820-573'),
(11,'Rua de Camões nº35','Guimarães','5673-356'),
(12,'Rua de Vila Flor nº14','Santarém','5235-456'),
(13,'Rua da Barrocanº7','Santarém','5235-578'),
(14,'Rua da Boa Vida nº99','Leiria','2550-563'),
(15,'Rua Padre António Vieira nº75','Caldas da Rainha','2550-453'),
(16,'Rua dos milagres nº66','Almada','2800-223'),
(17,'Travessa do Fernando Pessoa nº45','Leiria','2550-562'),
(18,'Rua da Albertina nº105','Guimarães','5673-521'),
(19,'Avenida Ferreira Borges nº25','Faro','8000-361'),
(20,'Avenida dos Bombeiros nº55','Aveiro','3810-482'),
(21,'Calçada Ribeiro Santos nº3','Lisboa','1150-928'),
(22,'Travessa das macieiras nº5','Lisboa','1150-445'),
(23,'Rua do Souto nº72','Évora','6821-463'),
(24,'Rua Alexandre Herculano nº32','Caldas da Rainha','2550-522'),
(25,'Rua Fernão Lourenço nº16','Almada','2800-392'),
(26,'Rua de O Século nº91','Coimbra','1234-777'),
(27,'Rua Quintinha nº23','Lisboa','1150-285'),
(28,'Rua Vinha nº66','Faro' ,'8000-435'),
(29,'Rua da Saudade nº47','Faro' ,'8000-623');

insert into `client` (`Client_ID`,`Client_Name`,`Client_Email` ,`Client_Phone`,`Location_ID`,`Client_NIF`,`Client_Age`,`Client_Category`) values
(1,'Carla Ventura','carla.ventura@MariaMaria.com' ,'919 456 948',1,'232 023 673',18,'Low'),
(2,'Mariana Pereira','mariana.pereira@MariaMaria.com','963 842 184',2,'165 285 935',34,'High'),
(3,'Raquel Pimenta','raquel.pimenta@MariaMaria.com','925 373 592',3,'462 573 423',23,'Medium'),
(4,'Maria Carolina Soares','maria.soares@MariaMaria.com','916 644 222',4,'385 642 563',30,'Extremely High'),
(5,'Francisca Pinto','francisca.pinto@MariaMaria.com','911 111 111',5,'163 492 284',32,'Extremely High'),
(6,'Margarida Sousa','margarida.sousa@MariaMaria.com','966 666 666',6,'482 845 777',35,'Extremely High'),
(7,'João Rafael' ,'joão.rafael@MariaMaria.com','927 775 324',7,'262 023 853',56,'Low'),
(8,'Margarida Pereira','margarida.pereira@MariaMaria.com','919 272 797',8,'356 859 482',40,'Low'),
(9,'Catarina Candeias','catarina.candeias@MariaMaria.com','967 888 333',9,'265 739 258',56,'High'),
(10,'Rita Ferreira','rita.ferreira@MariaMaria.com','913 287 543',10,'356 422 792',76,'Extremely High'),
(11,'Catarina Urbano' ,'catarina.urbano@MariaMaria.com','916 419 745',11,'159 346 314',16,'Extremely High'),
(12,'Tiago Gonçalves','tiago.gonçalves@MariaMaria.com','968 344 585',12,'274 135 899',88,'Medium'),
(13,'Rafaela Oliveira','rafaela.oliveira@MariaMaria.com','910 200 300',13,'345 642 266',18,'Low'),
(14,'Alice Silva','alice.silva@MariaMaria.com','916 374 954',14,'123 765 345',20,'High'),
(15,'Adriana Carvalho' ,'adriana.carvalho@MariaMaria.com','962 583 057',15,'237 972 121',22,'Medium'),
(16,'Leonor Duarte','leonor.duarte@MariaMaria.com','927 543 274',16,'356 427 752',24,'Extremely High'),
(17,'Duarte Jorge','duarte.jorge@MariaMaria.com','918 753 215',17,'295 467 532',26,'Low'),
(18,'Maria Helena Reis','maria.reis@MariaMaria.com','912 320 238',18,'256 583 632',28,'Medium'),
(19,'Matilde Mota','matilde.mota@MariaMaria.com','915 916 537',19,'257 899 421',30,'Low'),
(20,'Andreia Filipa','andreia.filipa@MariaMaria.com','925 820 161',20,'222 222 222',32,'Medium'),
(21,'Leonardo Rodrigues','leonardo.rodrigues@MariaMaria.com','918 161 418',21,'234 678 543',34,'Low'),
(22,'Ana Rita Frazão','ana.frazão@MariaMaria.com','928 151 718',22,'235 764 667',36,'Low'),
(23,'Sandra Dias','sandra.dias@MariaMaria.com','961 548 482',23,'333 567 632',38,'Low'),
(24,'José Ferreira','josé.ferreira@MariaMaria.com','924 792 333',24,'224 684 294',40,'High'),
(25,'Alexandra Matos','alexandra.matos@MariaMaria.com','917 931 432',25,'213 456 742',42,'Extremely High'),
(26,'Inês Gaspar','inês.gaspar@MariaMaria.com','967 601 003',26,'134 568 444',44,'Extremely High'),
(27,'Daniela Vasconcelos','daniela.vasconcelos@MariaMaria.com','925 682 356',27,'245 555 796',46,'Low'),
(28,'Isabel Soares','isabel.soares@MariaMaria.com','935 632 583',28,'273 499 486',48,'Extremely High'),
(29,'Carolina Pinto' ,'carolina.pinto@MariaMaria.com','916 314 428',29,'233 555 853',50,'Low');

insert into `product` (`Product_ID`,`Product_Name`,`Product_Color`,`Product_Size`,`Product_Price`,`Product_Description` ,`Product_Rating`) values

(5111,'Maria do Mar','Preto' ,'S',25,'Top de alças Preto tamanho S feito em lã',4.5),
(5121,'Maria do Mar','Bege','S',25,'Top de alças Bege tamanho S feito em lã',3.5),
(5131,'Maria do Mar','Rosa','S',25,'Top de alças Rosa tamanho S feito em lã',4.5),
(5141,'Maria do Mar','Azul','S',25,'Top de alças Azul tamanho S feito em lã',4.5),
(5151,'Maria do Mar','Verde','S',25,'Top de alças Verde tamanho S feito em lã',4.5),
(5112,'Maria do Mar','Preto' ,'M',27,'Top de alças Preto tamanho M feito em lã',4.5),
(5122,'Maria do Mar','Bege','M',27,'Top de alças Bege tamanho M feito em lã',3.5),
(5132,'Maria do Mar','Rosa','M',27,'Top de alças Rosa tamanho M feito em lã',4.5),
(5142,'Maria do Mar','Azul','M',27,'Top de alças Azul tamanho M feito em lã',4.5),
(5152,'Maria do Mar','Verde','M',27,'Top de alças Verde tamanho M feito em lã',4.5),
(5113,'Maria do Mar','Preto' ,'L',29,'Top de alças Preto tamanho L feito em lã',NULL),
(5123,'Maria do Mar','Bege','L',29,'Top de alças Bege tamanho L feito em lã',3.5),
(5133,'Maria do Mar','Rosa','L',29,'Top de alças Rosa tamanho L feito em lã',4.5),
(5143,'Maria do Mar','Azul','L',29,'Top de alças Azul tamanho L feito em lã',4.5),
(5153,'Maria do Mar','Verde','L',29,'Top de alças Verde tamanho L feito em lã',NULL),
(5114,'Maria do Mar','Preto' ,'XL',31,'Top de alças Preto tamanho XL feito em lã',NULL),
(5124,'Maria do Mar','Bege','XL',31,'Top de alças Bege tamanho XL feito em lã',3.5),
(5134,'Maria do Mar','Rosa','XL',31,'Top de alças Rosa tamanho XL feito em lã',4.5),
(5144,'Maria do Mar','Azul','XL',31,'Top de alças Azul tamanho XL feito em lã',NULL),
(5154,'Maria do Mar','Verde','XL',31,'Top de alças Verde tamanho XL feito em lã',NULL),
(5311,'Maria do Carmo' ,'Preto' ,'S',26,'Top de alças Preto tamanho S feito em lã',4.3),
(5321,'Maria do Carmo' ,'Bege','S',26,'Top de alças Bege tamanho S feito em lã',4.3),
(5331,'Maria do Carmo' ,'Rosa','S',26,'Top de alças Rosa tamanho S feito em lã',NULL),
(5341,'Maria do Carmo' ,'Azul','S',26,'Top de alças Azul tamanho S feito em lã',4.3),
(5351,'Maria do Carmo' ,'Verde','S',26,'Top de alças Verde tamanho S feito em lã',NULL),
(5312,'Maria do Carmo' ,'Preto' ,'M',28,'Top de alças Preto tamanho M feito em lã',4.3),
(5322,'Maria do Carmo' ,'Bege','M',28,'Top de alças Bege tamanho M feito em lã',4.3),
(5332,'Maria do Carmo' ,'Rosa','M',28,'Top de alças Rosa tamanho M feito em lã',4.3),
(5342,'Maria do Carmo' ,'Azul','M',28,'Top de alças Azul tamanho M feito em lã',4.3),
(5352,'Maria do Carmo' ,'Verde','M',28,'Top de alças Verde tamanho M feito em lã',4.3),
(5313,'Maria do Carmo' ,'Preto' ,'L',30,'Top de alças Preto tamanho L feito em lã',4.3),
(5323,'Maria do Carmo' ,'Bege','L',30,'Top de alças Bege tamanho L feito em lã',4.3),
(5333,'Maria do Carmo' ,'Rosa','L',30,'Top de alças Rosa tamanho L feito em lã',4.3),
(5343,'Maria do Carmo' ,'Azul','L',30,'Top de alças Azul tamanho L feito em lã',4.3),
(5353,'Maria do Carmo' ,'Verde','L',30,'Top de alças Verde tamanho L feito em lã',4.3),
(5314,'Maria do Carmo' ,'Preto' ,'XL',32,'Top de alças Preto tamanho XL feito em lã',4.3),
(5324,'Maria do Carmo' ,'Bege','XL',32,'Top de alças Bege tamanho XL feito em lã',4.3),
(5334,'Maria do Carmo' ,'Rosa','XL',32,'Top de alças Rosa tamanho XL feito em lã',4.3),
(5344,'Maria do Carmo' ,'Azul','XL',32,'Top de alças Azul tamanho XL feito em lã',4.3),
(5354,'Maria do Carmo' ,'Verde','XL',32,'Top de alças Verde tamanho XL feito em lã',4.3),
(5511,'Maria Leonor' ,'Preto','S',25.5,'Top de alças Preto tamanho S feito em algodão',NULL),
(5521,'Maria Leonor' ,'Bege','S',25.5,'Top de alças Bege tamanho S feito em algodão',NULL),
(5531,'Maria Leonor' ,'Rosa','S',25.5,'Top de alças Rosa tamanho S feito em algodão',NULL),
(5541,'Maria Leonor' ,'Azul','S',25.5,'Top de alças Azul tamanho S feito em algodão',NULL),
(5551,'Maria Leonor' ,'Verde','S',25.5,'Top de alças Verde tamanho S feito em algodão',NULL),
(5512,'Maria Leonor' ,'Preto','M',27.5,'Top de alças Preto tamanho M feito em algodão',NULL),
(5522,'Maria Leonor' ,'Bege','M',27.5,'Top de alças Bege tamanho M feito em algodão',NULL),
(5532,'Maria Leonor' ,'Rosa','M',27.5,'Top de alças Rosa tamanho M feito em algodão',NULL),
(5542,'Maria Leonor' ,'Azul','M',27.5,'Top de alças Azul tamanho M feito em algodão',NULL),
(5552,'Maria Leonor' ,'Verde','M',27.5,'Top de alças Verde tamanho M feito em algodão',NULL),
(5513,'Maria Leonor' ,'Preto','L',29.5,'Top de alças Preto tamanho L feito em algodão',NULL),
(5523,'Maria Leonor' ,'Bege','L',29.5,'Top de alças Bege tamanho L feito em algodão',NULL),
(5533,'Maria Leonor' ,'Rosa','L',29.5,'Top de alças Rosa tamanho L feito em algodão',NULL),
(5543,'Maria Leonor' ,'Azul','L',29.5,'Top de alças Azul tamanho L feito em algodão',NULL),
(5553,'Maria Leonor' ,'Verde','L',29.5,'Top de alças Verde tamanho L feito em algodão',NULL),
(5514,'Maria Leonor' ,'Preto','XL',31.5,'Top de alças Preto tamanho XL feito em algodão',NULL),
(5524,'Maria Leonor' ,'Bege','XL',31.5,'Top de alças Bege tamanho XL feito em algodão',NULL),
(5534,'Maria Leonor' ,'Rosa','XL',31.5,'Top de alças Rosa tamanho XL feito em algodão',NULL),
(5544,'Maria Leonor' ,'Azul','XL',31.5,'Top de alças Azul tamanho XL feito em algodão',NULL),
(5554,'Maria Leonor' ,'Verde','XL',31.5,'Top de alças Verde tamanho XL feito em algodão',NULL),
(5711,'Maria João','Preto' ,'S',26,'Top de alças Preto tamanho S feito em algodão',4.9),
(5721,'Maria João','Bege','S',26,'Top de alças Bege tamanho S feito em algodão',4.9),
(5731,'Maria João','Rosa','S',26,'Top de alças Rosa tamanho S feito em algodão',4.9),
(5741,'Maria João','Azul','S',26,'Top de alças Azul tamanho S feito em algodão',4.9),
(5751,'Maria João','Verde','S',26,'Top de alças Verde tamanho S feito em algodão',4.9),
(5712,'Maria João','Preto' ,'M',28,'Top de alças Preto tamanho M feito em algodão',4.9),
(5722,'Maria João','Bege','M',28,'Top de alças Bege tamanho M feito em algodão',4.9),
(5732,'Maria João','Rosa','M',28,'Top de alças Rosa tamanho M feito em algodão',4.9),
(5742,'Maria João','Azul','M',28,'Top de alças Azul tamanho M feito em algodão',4.9),
(5752,'Maria João','Verde','M',28,'Top de alças Verde tamanho M feito em algodão',4.9),
(5713,'Maria João','Preto' ,'L',30,'Top de alças Preto tamanho L feito em algodão',4.9),
(5723,'Maria João','Bege','L',30,'Top de alças Bege tamanho L feito em algodão',4.9),
(5733,'Maria João','Rosa','L',30,'Top de alças Rosa tamanho L feito em algodão',4.9),
(5743,'Maria João','Azul','L',30,'Top de alças Azul tamanho L feito em algodão',4.9),
(5753,'Maria João','Verde','L',30,'Top de alças Verde tamanho L feito em algodão',4.9),
(5714,'Maria João','Preto' ,'XL',32,'Top de alças Preto tamanho XL feito em algodão',4.9),
(5724,'Maria João','Bege','XL',32,'Top de alças Bege tamanho XL feito em algodão',4.9),
(5734,'Maria João','Rosa','XL',32,'Top de alças Rosa tamanho XL feito em algodão',4.9),
(5744,'Maria João','Azul','XL',32,'Top de alças Azul tamanho XL feito em algodão',4.9),
(5754,'Maria João','Verde','XL',32,'Top de alças Verde tamanho XL feito em algodão',4.9),
(5911,'Maria Teresa','Preto','S',24.5,'Top de alças Preto tamanho S feito em algodão',2.2),
(5921,'Maria Teresa','Bege','S',24.5,'Top de alças Bege tamanho S feito em algodão',2.2),
(5931,'Maria Teresa','Rosa','S',24.5,'Top de alças Rosa tamanho S feito em algodão',1.5),
(5941,'Maria Teresa','Azul','S',24.5,'Top de alças Azul tamanho S feito em algodão',2.2),
(5951,'Maria Teresa','Verde','S',24.5,'Top de alças Verde tamanho S feito em algodão',NULL),
(5912,'Maria Teresa','Preto','M',26.5,'Top de alças Preto tamanho M feito em algodão',2.2),
(5922,'Maria Teresa','Bege','M',26.5,'Top de alças Bege tamanho M feito em algodão',2.2),
(5932,'Maria Teresa','Rosa','M',26.5,'Top de alças Rosa tamanho M feito em algodão',1.5),
(5942,'Maria Teresa','Azul','M',26.5,'Top de alças Azul tamanho M feito em algodão',2.2),
(5952,'Maria Teresa','Verde','M',26.5,'Top de alças Verde tamanho M feito em algodão',NULL),
(5913,'Maria Teresa','Preto' ,'L',28.5,'Top de alças Preto tamanho L feito em algodão',2.2),
(5923,'Maria Teresa','Bege','L',28.5,'Top de alças Bege tamanho L feito em algodão',2.2),
(5933,'Maria Teresa','Rosa','L',28.5,'Top de alças Rosa tamanho L feito em algodão',1.5),
(5943,'Maria Teresa','Azul','L',28.5,'Top de alças Azul tamanho L feito em algodão',2.2),
(5953,'Maria Teresa','Verde','L',28.5,'Top de alças Verde tamanho L feito em algodão',NULL),
(5914,'Maria Teresa','Preto' ,'XL',30.5,'Top de alças Preto tamanho XL feito em algodão',2.2),
(5924,'Maria Teresa','Bege','XL',30.5,'Top de alças Bege tamanho XL feito em algodão',2.2),
(5934,'Maria Teresa','Rosa','XL',30.5,'Top de alças Rosa tamanho XL feito em algodão',1.5),
(5944,'Maria Teresa','Azul','XL',30.5,'Top de alças Azul tamanho XL feito em algodão',2.2),
(5954,'Maria Teresa','Verde','XL',30.5,'Top de alças Verde tamanho XL feito em algodão',2.2),
(6011,'Maria Discos','Uni' ,'Uni',6.5, 'discos de limpeza com bolsa',5); 




Insert into `costs` (`costs_id`,`Product_ID`,`Material`,`Material_price`,`labor_price`) values
(1,5111,'Lã',7.5,10),
(2,5121,'Lã',7.5,10),
(3,5131,'Lã',7.5,10),
(4,5141,'Lã',7.5,10),
(5,5151,'Lã',7.5,10),
(6,5112,'Lã',8.5,11),
(7,5122,'Lã',8.5,11),
(8,5132,'Lã',8.5,11),
(9,5142,'Lã',8.5,11),
(10,5152,'Lã',8.5,11),
(11,5113,'Lã',9.5,12),
(12,5123,'Lã',9.5,12),
(13,5133,'Lã',9.5,12),
(14,5143,'Lã',9.5,12),
(15,5153,'Lã',9.5,12),
(16,5114,'Lã',10.5,13),
(17,5124,'Lã',10.5,13),
(18,5134,'Lã',10.5,13),
(19,5144,'Lã',10.5,13),
(20,5154,'Lã',10.5,13),
(21,5311,'Lã',7.5,10),
(22,5321,'Lã',7.5,10),
(23,5331,'Lã',7.5,10),
(24,5341,'Lã',7.5,10),
(25,5351,'Lã',7.5,10),
(26,5312,'Lã',8.5,11),
(27,5322,'Lã',8.5,11),
(28,5332,'Lã',8.5,11),
(29,5342,'Lã',8.5,11),
(30,5352,'Lã',8.5,11),
(31,5313,'Lã',9.5,12),
(32,5323,'Lã',9.5,12),
(33,5333,'Lã',9.5,12),
(34,5343,'Lã',9.5,12),
(35,5353,'Lã',9.5,12),
(36,5314,'Lã',10.5,13),
(37,5324,'Lã',10.5,13),
(38,5334,'Lã',10.5,13),
(39,5344,'Lã',10.5,13),
(40,5354,'Lã',10.5,13),
(41,5511,'Algodão',6,10),
(42,5521,'Algodão',6,10),
(43,5531,'Algodão',6,10),
(44,5541,'Algodão',6,10),
(45,5551,'Algodão',6,10),
(46,5512,'Algodão',7,11),
(47,5522,'Algodão',7,11),
(48,5532,'Algodão',7,11),
(49,5542,'Algodão',7,11),
(50,5552,'Algodão',7,11),
(51,5513,'Algodão',8,12),
(52,5523,'Algodão',8,12),
(53,5533,'Algodão',8,12),
(54,5543,'Algodão',8,12),
(55,5553,'Algodão',8,12),
(56,5514,'Algodão',9,13),
(57,5524,'Algodão',9,13),
(58,5534,'Algodão',9,13),
(59,5544,'Algodão',9,13),
(60,5554,'Algodão',9,13),
(61,5711,'Algodão',6.5,10),
(62,5721,'Algodão',6.5,10),
(63,5731,'Algodão',6.5,10),
(64,5741,'Algodão',6.5,10),
(65,5751,'Algodão',6.5,10),
(66,5712,'Algodão',7.5,11),
(67,5722,'Algodão',7.5,11),
(68,5732,'Algodão',7.5,11),
(69,5742,'Algodão',7.5,11),
(70,5752,'Algodão',7.5,11),
(71,5713,'Algodão',8.5,12),
(72,5723,'Algodão',8.5,12),
(73,5733,'Algodão',8.5,12),
(74,5743,'Algodão',8.5,12),
(75,5753,'Algodão',8.5,12),
(76,5714,'Algodão',9.5,13),
(77,5724,'Algodão',9.5,13),
(78,5734,'Algodão',9.5,13),
(79,5744,'Algodão',9.5,13),
(80,5754,'Algodão',9.5,13),
(81,5911,'Algodão',6,8),
(82,5921,'Algodão',6,8),
(83,5931,'Algodão',6,8),
(84,5941,'Algodão',6,8),
(85,5951,'Algodão',6,8),
(86,5912,'Algodão',7,9),
(87,5922,'Algodão',7,9),
(88,5932,'Algodão',7,9),
(89,5942,'Algodão',7,9),
(90,5952,'Algodão',7,9),
(91,5913,'Algodão',8,10),
(92,5923,'Algodão',8,10),
(93,5933,'Algodão',8,10),
(94,5943,'Algodão',8,10),
(95,5953,'Algodão',8,10),
(96,5914,'Algodão',9,11),
(97,5924,'Algodão',9,11),
(98,5934,'Algodão',9,11),
(99,5944,'Algodão',9,11),
(100,5954,'Algodão',9,11),
(101,6011,'Algodão',1,3);

insert into `purchase` (`Purchase_ID`, `Client_ID`, `Date_Purchase`, `Purchase_Status`, `Purchase_Comments`, `Invoice_number`) values
(1,1,'2018-02-21','Entregue','',201801),
(2,2,'2018-02-25','Entregue','',201802),
(3,3,'2018-03-31','Entregue','',201803),
(4,4,'2018-04-05','Entregue','',201804),
(5,5,'2018-06-29','Entregue','',201805),
(6,6,'2018-07-06','Entregue','Se não estiver, entregar na vizinha da frente',201806),
(7,7,'2018-11-04','Entregue','',201807),
(8,8,'2018-12-23','Entregue','',201808),
(9,9,'2019-03-17','Entregue','',201901),
(10,10,'2019-03-22','Entregue','Ligar antes da entrega',201902),
(11,11,'2019-04-17','Entregue','',201903),
(12,12,'2019-06-15','Entregue','',201904),
(13,13,'2019-07-06','Entregue','',201905),
(14,14,'2019-07-15','Entregue','',201906),
(15,15,'2019-07-15','Entregue','',201907),
(16,16,'2019-07-15','Entregue','',201908),
(17,17,'2019-08-24','Entregue','',201909),
(18,18,'2019-09-29','Entregue','',201910),
(19,19,'2019-12-15','Entregue','',201911),
(20,20,'2020-01-15','Entregue','',202001),
(21,21,'2020-04-25','Entregue','',202002),
(22,22,'2020-05-03','Entregue','',202003),
(23,23,'2020-05-25','Entregue','',202004),
(24,24,'2020-05-29','Entregue','',202005),
(25,25,'2020-08-01','Entregue','',202006),
(26,26,'2020-10-15','Entregue','Tem pressa para receber',202007),
(27,27,'2020-11-02','Entregue','',202008),
(28,28,'2020-12-10','Entregue','',202009),
(29,29,'2020-12-11','Entregue','',202010),
(30,10,'2020-12-23','Em distribuição','',202011),
(31,6,'2020-12-26','Em processamento','Embrulho de presente',202012);

insert into `item_purchase` (`Purchase_ID`,`Product_ID`,`Number_Items` ,`Discount`) values
(1,5132,1,0.1),
(1,5144,1,0),
(2,5131,1,0),
(3,5314,1,0),
(4,5523,2,0),
(5,5943,1,0),
(6,5934,1,0),
(7,6011,3,0),
(8,6011,5,0),
(9,5522,1,0),
(10,5744,2,0),
(10,5954,1,0),
(11,5142,1,0),
(12,5131,3,0),
(13,5332,1,0),
(13,5314,2,0.15),
(14,5313,1,0),
(15,5153,1,0),
(16,6011,1,0),
(17,5111,1,0.23),
(18,5312,2,0),
(19,5921,3,0),
(20,5953,3,0),
(21,5321,1,0),
(22,5332,1,0),
(23,6011,1,0),
(24,5713,2,0),
(25,5514,2,0),
(26,5114,5,0),
(27,6011,2,0),
(28,5352,1,0),
(29,6011,1,0),
(30,6011,6,0),
(30,5951,2,0.5),
(31,5933,2,0),
(31,5522,1,0);

insert into `stock` (`stock_id`,`Product_ID`,`Stock_Quantity`) values
(1,5111,126),
(2,5121,157),
(3,5131,147),
(4,5141,178),
(5,5151,210),
(6,5112,136),
(7,5122,262),
(8,5132,220),
(9,5142,168),
(10,5152,178),
(11,5113,157),
(12,5123,147),
(13,5133,220),
(14,5143,126),
(15,5153,105),
(16,5114,220),
(17,5124,262),
(18,5134,126),
(19,5144,115),
(20,5154,210),
(21,5311,199),
(22,5321,168),
(23,5331,147),
(24,5341,136),
(25,5351,126),
(26,5312,178),
(27,5322,241),
(28,5332,199),
(29,5342,231),
(30,5352,168),
(31,5313,136),
(32,5323,115),
(33,5333,73),
(34,5343,52),
(35,5353,0),
(36,5314,126),
(37,5324,42),
(38,5334,94),
(39,5344,168),
(40,5354,21),
(41,5511,189),
(42,5521,168),
(43,5531,147),
(44,5541,126),
(45,5551,94),
(46,5512,73),
(47,5522,231),
(48,5532,199),
(49,5542,189),
(50,5552,147),
(51,5513,210),
(52,5523,199),
(53,5533,178),
(54,5543,147),
(55,5553,157),
(56,5514,157),
(57,5524,10),
(58,5534,178),
(59,5544,147),
(60,5554,178),
(61,5711,178),
(62,5721,210),
(63,5731,241),
(64,5741,220),
(65,5751,199),
(66,5712,178),
(67,5722,157),
(68,5732,136),
(69,5742,115),
(70,5752,94),
(71,5713,42),
(72,5723,199),
(73,5733,189),
(74,5743,147),
(75,5753,157),
(76,5714,231),
(77,5724,189),
(78,5734,168),
(79,5744,136),
(80,5754,63),
(81,5911,147),
(82,5921,0),
(83,5931,52),
(84,5941,105),
(85,5951,157),
(86,5912,210),
(87,5922,115),
(88,5932,168),
(89,5942,126),
(90,5952,231),
(91,5913,31),
(92,5923,73),
(93,5933,115),
(94,5943,189),
(95,5953,147),
(96,5914,136),
(97,5924,157),
(98,5934,126),
(99,5944,178),
(100,5954,105),
(101,6011,367);