USE GD1C2016
GO

CREATE SCHEMA SALUDOS AUTHORIZATION gd
GO

CREATE TABLE SALUDOS.PUBLICACIONES(
	PUBL_COD			numeric(18,0) IDENTITY, --Publicacion_Cod
	PUBL_DESCRIPCION	nvarchar(255),			--Publicacion_Descripcion
	PUBL_STOCK			numeric (18,0),			--Publicacion_Stock
	PUBL_INICIO			datetime,				--Publicacion_Fecha
	PUBL_FINALIZACION	datetime,				--Publicacion_Fecha_Venc
	PUBL_PRECIO			numeric(18,2),			--Publicacion_Precio
	PUBL_PREGUNTAS		bit,					--new
	PUBL_PERMITE_ENVIO	bit,					--new
	USUA_USERNAME		nvarchar(255),			--FK. Creador.
	VISI_COD			int,					--FK. Visibilidad.
	RUBR_COD			int,					--FK. Rubro.
	ESTA_COD			int,					--FK. Estado.
	TIPO_COD			int,					--Fk. Tipo.
	CONSTRAINT PK_PUBLICACIONES PRIMARY KEY (PUBL_COD),
)

CREATE TABLE SALUDOS.ESTADOS(
	ESTA_COD	int IDENTITY,	--PK. 
	ESTA_NOMBRE	nvarchar(255)	--Publicacion_Estado. Reemplaza Publicada.
	CONSTRAINT CK_ESTA_NOMBRE CHECK
		(ESTA_NOMBRE IN ('Borrador', 'Activa', 'Pausada', 'Finalizada')),
	CONSTRAINT PK_ESTADOS PRIMARY KEY (ESTA_COD),
)

CREATE TABLE SALUDOS.TIPOS(
	TIPO_COD	int IDENTITY,	--PK.
	TIPO_NOMBRE	nvarchar(255)	--Publicacion_Tipo.
	CONSTRAINT CK_TIPO_NOMBRE CHECK
		(TIPO_NOMBRE IN ('Compra Inmediata', 'Subasta')),
	CONSTRAINT PK_TIPOS PRIMARY KEY (TIPO_COD),
)

CREATE TABLE SALUDOS.VISIBILIDADES(
	VISI_COD					int,	--reemplaza Publiacion_Visibilidad_Cod
	VISI_COMISION_PUBLICACION	numeric(18,2),	--Publicacion_Visibilidad_Precio
	VISI_COMISION_VENTA			numeric(18,2),	--Publicacion_Visibilidad_Porcentaje
	VISI_COMISION_ENVIO			numeric(18,2),	--new. 10% del valor inicial de la publicaci�n.
	VISI_DESCRIPCION			nvarchar(255),	--Publicacion_Visibilidad_Desc
	CONSTRAINT PK_VISIBILIDADES PRIMARY KEY (VISI_COD),
)

CREATE TABLE SALUDOS.RUBROS(
	RUBR_COD			int IDENTITY,	--new
	RUBR_NOMBRE			nvarchar(255),	--Publicacion_Rubro_Descripcion
	RUBR_DESCRIPCION	nvarchar(255),	--new
	CONSTRAINT PK_RUBROS PRIMARY KEY (RUBR_COD),
)

CREATE TABLE SALUDOS.TRANSACCIONES(
	TRAN_COD				int	IDENTITY,	--new
	TRAN_ADJUDICADA			bit,			--Si fue adjudicada (para subastas)
	TRAN_PRECIO				numeric(18,2),	--Oferta_Monto (en caso de subasta). Sino, es el precio de compra.
	TRAN_CANTIDAD_COMPRADA	numeric(2,0),	--Compra_Cantidad. Siempre es 1 en caso de subastas.
	TRAN_FECHA				datetime,		--Compra_Fecha u Oferta_Fecha. Momento de la transacci�n.
	TRAN_FORMA_PAGO			nvarchar(255),	--Forma_Pago_Desc.
	USUA_USERNAME			nvarchar(255),	--FK. Comprador/ofertante.
	PUBL_COD				numeric(18,0),	--FK. Qu� compra u oferta.
	TIPO_COD				int				--FK. Compra o subasta.
	CONSTRAINT PK_TRANSACCIONES PRIMARY KEY (TRAN_COD),
)

CREATE TABLE SALUDOS.CALIFICACIONES(
	CALI_COD				int	IDENTITY,	--Calificacion_Codigo
	CALI_ESTRELLAS			numeric(18,0),	--Calificacion_Cant_Estrellas
	CALI_DESCRIPCION		nvarchar(255),	--Calificacion_Descripcion
	CALI_FECHA				datetime,		--new
	USUA_USERNAME			nvarchar(255),	--FK. Qui�n califica.
	PUBL_COD				numeric(18,0),	--FK. Respecto de qu� publicaci�n califica.
	CONSTRAINT PK_CALIFICACIONES PRIMARY KEY (CALI_COD),
)

CREATE TABLE SALUDOS.EMPRESAS(
	EMPR_COD				int IDENTITY,	--new
	EMPR_RAZON_SOCIAL		nvarchar(255),	--Publ_Empresa_Razon_Social
	EMPR_CUIT				nvarchar(50),	--Publ_Empresa_Cuit
	EMPR_MAIL				nvarchar(50),	--Publ_Empresa_Mail
	EMPR_TELEFONO			numeric(18,0),	--new
	EMPR_CALLE				nvarchar(100),	--Publ_Empresa_Dom_Calle
	EMPR_NRO_CALLE			numeric(18,0),	--Publ_Empresa_Nro_Calle
	EMPR_PISO				numeric(18,0),	--Publ_Empresa_Piso
	EMPR_DEPTO				nvarchar(50),	--Publ_Empresa_Depto
	EMPR_CIUDAD				nvarchar(50),	--new
	EMPR_CONTACTO			nvarchar(50),	--new
	EMPR_CODIGO_POSTAL		nvarchar(50),	--Publ_Empresa_Cod_Postal
	EMPR_LOCALIDAD			nvarchar(50),	--new
	EMPR_FECHA_CREACION		datetime,		--Publ_Empresa_Fecha_Creacion
	USUA_USERNAME			nvarchar(255),	--FK. Usuario de la empresa.
	RUBR_COD				int,			--FK. Rubro principal donde se desempe�a.
	CONSTRAINT PK_EMPRESAS PRIMARY KEY (EMPR_COD)
)

CREATE TABLE SALUDOS.CLIENTES(				--PARA EL QUE PUBLICA / PARA EL QUE COMPRA
	CLIE_COD				int IDENTITY,	--new
	CLIE_NOMBRE				nvarchar(255),	--Publ_Cli_Nombre	  / Cli_Nombre
	CLIE_APELLIDO			nvarchar(255),	--Publ_Cli_Apeliido   / Cli_Apeliido
	CLIE_TELEFONO			numeric(18,0),	--new
	CLIE_CALLE				nvarchar(255),	--Publ_Cli_Dom_Calle  / Cli_Dom_Calle
	CLIE_NRO_CALLE			numeric(18,0),	--Publ_Cli_Nro_Calle  / Cli_Nro_Calle
	CLIE_FECHA_CREACION		datetime,		--new
	CLIE_FECHA_NACIMIENTO	datetime,		--Publ_Cli_Fecha_Nac  / Cli_Fecha_Nac
	CLIE_CODIGO_POSTAL		nvarchar(50),	--Publ_Cli_Cod_Postal / Cli_Cod_Postal
	CLIE_DEPTO				nvarchar(50),	--Publ_Cli_Depto	  / Cli_Depto
	CLIE_PISO				numeric(18,0),	--Publ_Cli_Piso		  / Cli_Piso
	CLIE_LOCALIDAD			nvarchar(255),	--new
	CLIE_NRO_DOCUMENTO		numeric(18,0),	--Publ_Cli_Dni		  / Cli_Dni
	CLIE_TIPO_DOCUMENTO		nvarchar(50),	--new
	CLIE_MAIL				nvarchar(50),	--Publ_Cli_Mail		  / Cli_Mail
	USUA_USERNAME			nvarchar(255),	--FK. Usuario del cliente.
	CONSTRAINT PK_CLIENTES PRIMARY KEY (CLIE_COD)
)

CREATE TABLE SALUDOS.USUARIOS(
	USUA_USERNAME			nvarchar(255),		--new
	USUA_PASSWORD			nvarchar(255),		--new
	USUA_NUEVO				bit DEFAULT 0,		--new
	USUA_INTENTOS_LOGIN		tinyint DEFAULT 0,	--new
	USUA_TIPO				nvarchar(255),		--new.
	USUA_HABILITADO			bit DEFAULT 1,
	CONSTRAINT CK_USUA_TIPO CHECK (USUA_TIPO IN ('Empresa', 'Cliente')),
	CONSTRAINT PK_USUA_USERNAME PRIMARY KEY (USUA_USERNAME)
)

CREATE TABLE SALUDOS.FACTURAS(
	FACT_COD				numeric(18,0) IDENTITY,	--Factura_Nro
	FACT_FECHA				datetime,				--Factura_Fecha
	FACT_TOTAL				numeric(18,2),			--Factura_Total
	USUA_USERNAME			nvarchar(255),			--FK. A qui�n corresponde la factura.
	PUBL_COD				numeric(18,0),			--FK. Por qu� publicaci�n se factura.
	CONSTRAINT PK_FACTURAS PRIMARY KEY (FACT_COD)
)

CREATE TABLE SALUDOS.ITEMS(
	ITEM_COD				int	IDENTITY,	--new
	ITEM_IMPORTE			numeric(18,2),	--Item_Factura_Monto
	ITEM_CANTIDAD			numeric(2,0),	--Item_Factura_Cantidad
	ITEM_DESCRIPCION		nvarchar(255),	--new. A qu� corresponde el cobro.
	FACT_COD				numeric(18,0),	--FK. Factura a la que pertenece.
	CONSTRAINT CK_ITEM_DESCRIPCION CHECK
		(ITEM_DESCRIPCION IN ('Comisi�n por Publicaci�n', 'Comisi�n por Venta', 'Comisi�n por env�o')), 
	CONSTRAINT PK_ITEMS PRIMARY KEY (ITEM_COD)
)

CREATE TABLE SALUDOS.ROLES(
	ROL_COD			int IDENTITY,
	ROL_NOMBRE		nvarchar(50),
	ROL_HABILITADO	bit DEFAULT 1,
	CONSTRAINT PK_ROLES PRIMARY KEY (ROL_COD)
)

CREATE TABLE SALUDOS.FUNCIONALIDADES(
	FUNC_COD		int IDENTITY,
	FUNC_NOMBRE		nvarchar(50),
	CONSTRAINT PK_FUNCIONALIDADES PRIMARY KEY (FUNC_COD)
)

CREATE TABLE SALUDOS.ROLESXUSUARIO(
	ROL_COD			int,
	USUA_USERNAME	nvarchar(255),
	RXU_HABILITADO	bit DEFAULT 1,
	CONSTRAINT PK_ROLESXUSUARIO PRIMARY KEY (ROL_COD, USUA_USERNAME)
)

CREATE TABLE SALUDOS.FUNCIONALIDADESXROL(
	FUNC_COD		int,
	ROL_COD			int,
	CONSTRAINT PK_FUNCIONALIDADESXROL PRIMARY KEY (FUNC_COD, ROL_COD)
)


-----------FKs QUE HAY QUE AGREGAR-----------
ALTER TABLE SALUDOS.PUBLICACIONES
	ADD CONSTRAINT FK_PUBLICACIONES_USUA_USERNAME
	FOREIGN KEY (USUA_USERNAME)
	REFERENCES SALUDOS.USUARIOS(USUA_USERNAME)

ALTER TABLE SALUDOS.PUBLICACIONES
	ADD CONSTRAINT FK_PUBLICACIONES_VISI_COD
	FOREIGN KEY (VISI_COD)
	REFERENCES SALUDOS.VISIBILIDADES(VISI_COD)

ALTER TABLE SALUDOS.PUBLICACIONES
	ADD CONSTRAINT FK_PUBLICACIONES_RUBR_COD
	FOREIGN KEY (RUBR_COD)
	REFERENCES SALUDOS.RUBROS(RUBR_COD)

ALTER TABLE SALUDOS.PUBLICACIONES
	ADD CONSTRAINT FK_PUBLICACIONES_ESTA_COD
	FOREIGN KEY (ESTA_COD)
	REFERENCES SALUDOS.ESTADOS(ESTA_COD)

ALTER TABLE SALUDOS.PUBLICACIONES
	ADD CONSTRAINT FK_PUBLICACIONES_TIPO_COD
	FOREIGN KEY (TIPO_COD)
	REFERENCES SALUDOS.TIPOS(TIPO_COD)


ALTER TABLE SALUDOS.TRANSACCIONES
	ADD CONSTRAINT FK_TRANSACCIONES_USUA_USERNAME
	FOREIGN KEY (USUA_USERNAME)
	REFERENCES SALUDOS.USUARIOS(USUA_USERNAME)

ALTER TABLE SALUDOS.TRANSACCIONES
	ADD CONSTRAINT FK_TRANSACCIONES_PUBL_COD
	FOREIGN KEY (PUBL_COD)
	REFERENCES SALUDOS.PUBLICACIONES(PUBL_COD)

ALTER TABLE SALUDOS.TRANSACCIONES
	ADD CONSTRAINT FK_TRANSACCIONES_TIPO_COD
	FOREIGN KEY (TIPO_COD)
	REFERENCES SALUDOS.TIPOS(TIPO_COD)


ALTER TABLE SALUDOS.CALIFICACIONES
	ADD CONSTRAINT FK_CALIFICACIONES_USUA_USERNAME
	FOREIGN KEY (USUA_USERNAME)
	REFERENCES SALUDOS.USUARIOS(USUA_USERNAME)

ALTER TABLE SALUDOS.CALIFICACIONES
	ADD CONSTRAINT FK_CALIFICACIONES_PUBL_COD
	FOREIGN KEY (PUBL_COD)
	REFERENCES SALUDOS.PUBLICACIONES(PUBL_COD)


ALTER TABLE SALUDOS.EMPRESAS
	ADD CONSTRAINT FK_EMPRESAS_USUA_USERNAME
	FOREIGN KEY (USUA_USERNAME)
	REFERENCES SALUDOS.USUARIOS(USUA_USERNAME)

ALTER TABLE SALUDOS.EMPRESAS
	ADD CONSTRAINT FK_EMPRESAS_RUBR_COD
	FOREIGN KEY (RUBR_COD)
	REFERENCES SALUDOS.RUBROS(RUBR_COD)


ALTER TABLE SALUDOS.CLIENTES
	ADD CONSTRAINT FK_CLIENTES_USUA_USERNAME
	FOREIGN KEY (USUA_USERNAME)
	REFERENCES SALUDOS.USUARIOS(USUA_USERNAME)


ALTER TABLE SALUDOS.FACTURAS
	ADD CONSTRAINT FK_FACTURAS_USUA_USERNAME
	FOREIGN KEY (USUA_USERNAME)
	REFERENCES SALUDOS.USUARIOS(USUA_USERNAME)

ALTER TABLE SALUDOS.FACTURAS
	ADD CONSTRAINT FK_FACTURAS_PUBL_COD
	FOREIGN KEY (PUBL_COD)
	REFERENCES SALUDOS.PUBLICACIONES(PUBL_COD)


ALTER TABLE SALUDOS.ITEMS
	ADD CONSTRAINT FK_ITEMS_FACT_COD
	FOREIGN KEY (FACT_COD)
	REFERENCES SALUDOS.FACTURAS(FACT_COD)


ALTER TABLE SALUDOS.ROLESXUSUARIO
	ADD CONSTRAINT FK_ROLESXUSUARIO_ROL_COD
	FOREIGN KEY (ROL_COD)
	REFERENCES SALUDOS.ROLES(ROL_COD)

ALTER TABLE SALUDOS.ROLESXUSUARIO
	ADD CONSTRAINT FK_ROLESXUSUARIO_USUA_USERNAME
	FOREIGN KEY (USUA_USERNAME)
	REFERENCES SALUDOS.USUARIOS(USUA_USERNAME)


ALTER TABLE SALUDOS.FUNCIONALIDADESXROL
	ADD CONSTRAINT FK_FUNCIONALIDADESXROL_FUNC_COD
	FOREIGN KEY (FUNC_COD)
	REFERENCES SALUDOS.FUNCIONALIDADES(FUNC_COD)

ALTER TABLE SALUDOS.FUNCIONALIDADESXROL
	ADD CONSTRAINT FK_FUNCIONALIDADESXROL_ROL_COD
	FOREIGN KEY (ROL_COD)
	REFERENCES SALUDOS.ROLES(ROL_COD)


--Agregando roles.
INSERT INTO SALUDOS.ROLES (ROL_NOMBRE)
	VALUES ('Administrador'), ('Cliente'), ('Empresa')


--Agregando funcionalidades.
INSERT INTO SALUDOS.FUNCIONALIDADES(FUNC_NOMBRE)
	VALUES	('ABM Roles'),
			('ABM Usuarios'),
			('ABM Rubros'),
			('ABM Visibilidades'),
			('Vender'),
			('Comprar/Ofertar'),
			('Historial de cliente'),
			('Calificar al vendedor'),
			('Consulta de facturas'),
			('Listado estad�stico')


--Agregando funcionalidades por cada rol.
INSERT INTO SALUDOS.FUNCIONALIDADESXROL(
	ROL_COD, FUNC_COD)
SELECT
	ROL_COD, FUNC_COD
FROM SALUDOS.ROLES, SALUDOS.FUNCIONALIDADES
WHERE	(ROL_NOMBRE = 'Cliente' AND
			FUNC_NOMBRE IN ('Vender', 'Comprar/Ofertar', 'Historial de cliente', 'Calificar al vendedor', 'Consulta de facturas')) OR
		(ROL_NOMBRE = 'Empresa' AND
			FUNC_NOMBRE IN ('Vender', 'Consulta de facturas')) OR
		(ROL_NOMBRE = 'Administrador' AND
			FUNC_NOMBRE LIKE '%')


--La tabla maestra tiene datos de clientes guardados en dos lugares distintos.
--Primero se migran clientes que hayan hecho una publicaci�n.
INSERT INTO SALUDOS.CLIENTES(
	CLIE_NRO_DOCUMENTO, CLIE_APELLIDO, CLIE_NOMBRE, CLIE_FECHA_NACIMIENTO, CLIE_MAIL,
	CLIE_CALLE, CLIE_NRO_CALLE, CLIE_PISO, CLIE_DEPTO, CLIE_CODIGO_POSTAL, CLIE_TIPO_DOCUMENTO)
SELECT DISTINCT
	Publ_Cli_Dni, Publ_Cli_Apeliido, Publ_Cli_Nombre, Publ_Cli_Fecha_Nac, Publ_Cli_Mail,
	Publ_Cli_Dom_Calle, Publ_Cli_Nro_Calle, Publ_Cli_Piso, Publ_Cli_Depto, Publ_Cli_Cod_Postal, 'DNI'
FROM gd_esquema.Maestra
WHERE Publ_Cli_Dni IS NOT NULL


--Luego se migran clientes que hayan realizado una compra.
INSERT INTO SALUDOS.CLIENTES(
	CLIE_NRO_DOCUMENTO, CLIE_APELLIDO, CLIE_NOMBRE, CLIE_FECHA_NACIMIENTO, CLIE_MAIL,
	CLIE_CALLE, CLIE_NRO_CALLE, CLIE_PISO, CLIE_DEPTO, CLIE_CODIGO_POSTAL, CLIE_TIPO_DOCUMENTO)
SELECT DISTINCT
	Cli_Dni, Cli_Apeliido, Cli_Nombre, Cli_Fecha_Nac, Cli_Mail,
	Cli_Dom_Calle, Cli_Nro_Calle, Cli_Piso, Cli_Depto, Cli_Cod_Postal, 'DNI'
FROM gd_esquema.Maestra
WHERE	Cli_Dni IS NOT NULL
		AND NOT EXISTS(
		SELECT CLIE_NRO_DOCUMENTO
		FROM SALUDOS.CLIENTES
		WHERE Cli_Dni = CLIE_NRO_DOCUMENTO)
--Resulta que a pesar de que la informaci�n est� dos veces,
--los 28 clientes son los mismos. As� que esto no hace nada:
--0 rows affected. Pero me parece que tiene sentido dejarlo.


--Migrando empresas.
INSERT INTO SALUDOS.EMPRESAS(
	EMPR_RAZON_SOCIAL, EMPR_CUIT, EMPR_FECHA_CREACION,
	EMPR_MAIL, EMPR_CALLE, EMPR_NRO_CALLE,
	EMPR_PISO, EMPR_DEPTO, EMPR_CODIGO_POSTAL)
SELECT DISTINCT
	Publ_Empresa_Razon_Social, Publ_Empresa_Cuit, Publ_Empresa_Fecha_Creacion,
	Publ_Empresa_Mail, Publ_Empresa_Dom_Calle, Publ_Empresa_Nro_Calle,
	Publ_Empresa_Piso, Publ_Empresa_Depto, Publ_Empresa_Cod_Postal
FROM gd_esquema.Maestra
WHERE Publ_Empresa_Razon_Social IS NOT NULL


--Migrando rubros.
INSERT INTO SALUDOS.RUBROS(
	RUBR_NOMBRE)
SELECT DISTINCT
	Publicacion_Rubro_Descripcion
FROM gd_esquema.Maestra
WHERE Publicacion_Rubro_Descripcion IS NOT NULL


--Migrando visibilidades.
INSERT INTO SALUDOS.VISIBILIDADES(
	VISI_COD, VISI_DESCRIPCION, VISI_COMISION_ENVIO,
	VISI_COMISION_PUBLICACION, VISI_COMISION_VENTA)
SELECT DISTINCT
	Publicacion_Visibilidad_Cod, Publicacion_Visibilidad_Desc, 0.10,
	Publicacion_Visibilidad_Precio, Publicacion_Visibilidad_Porcentaje
FROM gd_esquema.Maestra

GO


--Creando usuarios para clientes.
INSERT INTO SALUDOS.USUARIOS(
	USUA_USERNAME,
	USUA_PASSWORD,
	USUA_TIPO)
SELECT DISTINCT
	(LOWER(CLIE_NOMBRE) + LOWER(CLIE_APELLIDO)),
	HASHBYTES('SHA2_256', CONVERT(nvarchar(255), CLIE_NRO_DOCUMENTO)),
	'Cliente'
FROM SALUDOS.CLIENTES

UPDATE SALUDOS.CLIENTES
SET SALUDOS.CLIENTES.USUA_USERNAME = USUARIOS.USUA_USERNAME
FROM (
	SELECT USUA_USERNAME
	FROM SALUDOS.USUARIOS) USUARIOS
WHERE
	USUARIOS.USUA_USERNAME = LOWER(SALUDOS.CLIENTES.CLIE_NOMBRE) + LOWER(SALUDOS.CLIENTES.CLIE_APELLIDO)


--Creando usuarios para empresas.
INSERT INTO SALUDOS.USUARIOS(
	USUA_USERNAME,
	USUA_PASSWORD,
	USUA_TIPO)
SELECT DISTINCT
	LOWER(EMPR_RAZON_SOCIAL),
	HASHBYTES('SHA2_256', EMPR_RAZON_SOCIAL),
	'Empresa'
FROM SALUDOS.EMPRESAS

UPDATE SALUDOS.EMPRESAS
SET SALUDOS.EMPRESAS.USUA_USERNAME = USUARIOS.USUA_USERNAME
FROM (
	SELECT USUA_USERNAME
	FROM SALUDOS.USUARIOS) USUARIOS
WHERE
	USUARIOS.USUA_USERNAME = LOWER(SALUDOS.EMPRESAS.EMPR_RAZON_SOCIAL)

GO


--Agregando estados.
INSERT INTO SALUDOS.ESTADOS(
	ESTA_NOMBRE)
VALUES ('Activa'), ('Finalizada'), ('Borrador'), ('Pausada')


--Agregando tipos.
INSERT INTO SALUDOS.TIPOS(
	TIPO_NOMBRE)
VALUES ('Compra Inmediata'), ('Subasta')

GO


--Migrando publicaciones.
--En primera instancia, todas se migran con estado Activa, porque se desconoce la fecha actual.
--Al iniciar la aplicaci�n se revisa qu� publicaciones deben pasarse a Finalizadas.
SET IDENTITY_INSERT SALUDOS.PUBLICACIONES ON;

INSERT INTO SALUDOS.PUBLICACIONES(
	PUBL_COD, PUBL_DESCRIPCION, PUBL_STOCK,
	PUBL_INICIO, PUBL_FINALIZACION, PUBL_PRECIO,
	PUBL_PREGUNTAS, PUBL_PERMITE_ENVIO, VISI_COD,
	ESTA_COD, TIPO_COD,	USUA_USERNAME, RUBR_COD
	)
SELECT DISTINCT
	Publicacion_Cod, Publicacion_Descripcion, Publicacion_Stock,
	Publicacion_Fecha, Publicacion_Fecha_Venc, Publicacion_Precio,
	0, 0, Publicacion_Visibilidad_Cod,
	
	(SELECT ESTA_COD
	FROM SALUDOS.ESTADOS
	WHERE ESTA_NOMBRE = 'Activa'),

	(SELECT TIPO_COD
	FROM SALUDOS.TIPOS
	WHERE TIPO_NOMBRE = Publicacion_Tipo),

	(SELECT USUA_USERNAME
	FROM SALUDOS.USUARIOS
	WHERE	(USUA_USERNAME = LOWER(Publ_Cli_Nombre) + LOWER(Publ_Cli_Apeliido))
		OR	(USUA_USERNAME = LOWER(Publ_Empresa_Razon_Social))),

	(SELECT RUBR_COD
	FROM SALUDOS.RUBROS
	WHERE RUBR_NOMBRE = Publicacion_Rubro_Descripcion)
FROM gd_esquema.Maestra

SET IDENTITY_INSERT SALUDOS.PUBLICACIONES OFF;

GO


--Migrando facturas.
SET IDENTITY_INSERT SALUDOS.FACTURAS ON;

INSERT INTO SALUDOS.FACTURAS(
	FACT_COD, FACT_FECHA,
	FACT_TOTAL, PUBL_COD,
	USUA_USERNAME)
SELECT DISTINCT
	Factura_Nro, Factura_Fecha,
	Factura_Total, Publicacion_Cod,

	(SELECT USUA_USERNAME
	FROM SALUDOS.USUARIOS
	WHERE	(USUA_USERNAME = LOWER(Publ_Cli_Nombre) + LOWER(Publ_Cli_Apeliido))
		OR	(USUA_USERNAME = LOWER(Publ_Empresa_Razon_Social)))
FROM gd_esquema.Maestra
WHERE Factura_Nro IS NOT NULL

SET IDENTITY_INSERT SALUDOS.FACTURAS OFF;


--Migrando items.
INSERT INTO SALUDOS.ITEMS(
	ITEM_IMPORTE, ITEM_CANTIDAD,
	FACT_COD, ITEM_DESCRIPCION)
SELECT DISTINCT
	Item_Factura_Monto, Item_Factura_Cantidad,
	Factura_Nro,
	CASE
		WHEN Item_Factura_Monto = Publicacion_Visibilidad_Precio
				THEN 'Comisi�n por Publicaci�n'
		ELSE 'Comisi�n por Venta'
	END
FROM gd_esquema.Maestra
WHERE Item_Factura_Monto IS NOT NULL


--Migrando transacciones de Compras Inmediatas.
INSERT INTO SALUDOS.TRANSACCIONES(
	PUBL_COD, TRAN_PRECIO, TRAN_FORMA_PAGO,
	TRAN_CANTIDAD_COMPRADA, TRAN_FECHA, TRAN_ADJUDICADA,
	TIPO_COD,
	USUA_USERNAME)

SELECT DISTINCT
	Publicacion_Cod, Publicacion_Precio, Forma_Pago_Desc,
	Compra_Cantidad, Compra_Fecha, 1,

	(SELECT TIPO_COD
	FROM SALUDOS.TIPOS
	WHERE TIPO_NOMBRE = Publicacion_Tipo),

	LOWER(Cli_Nombre) + LOWER(Cli_Apeliido)
FROM gd_esquema.Maestra
WHERE Compra_Fecha IS NOT NULL AND Publicacion_Tipo = 'Compra Inmediata'

GO


--Migrando transacciones de Subastas.
INSERT INTO SALUDOS.TRANSACCIONES(
	PUBL_COD, TRAN_PRECIO, TRAN_FORMA_PAGO,
	TRAN_CANTIDAD_COMPRADA, TRAN_FECHA,
	TRAN_ADJUDICADA,
	TIPO_COD,
	USUA_USERNAME)

SELECT DISTINCT
	Publicacion_Cod, Oferta_Monto, Forma_Pago_Desc,
	1, Oferta_Fecha,

	CASE
		WHEN Oferta_Monto = (SELECT MAX(Oferta_Monto)
							FROM gd_esquema.Maestra t2
							WHERE Oferta_Monto IS NOT NULL AND t2.Publicacion_Cod = t1.Publicacion_Cod)
			THEN 1
		ELSE 0
	END,

	(SELECT TIPO_COD
	FROM SALUDOS.TIPOS
	WHERE TIPO_NOMBRE = Publicacion_Tipo),

	LOWER(Cli_Nombre) + LOWER(Cli_Apeliido)
FROM gd_esquema.Maestra t1
WHERE Oferta_Fecha IS NOT NULL AND Publicacion_Tipo = 'Subasta'

GO


--Migrando calificaciones.
SET IDENTITY_INSERT SALUDOS.CALIFICACIONES ON;

INSERT INTO SALUDOS.CALIFICACIONES(
	CALI_COD, CALI_ESTRELLAS,
	CALI_DESCRIPCION, PUBL_COD, USUA_USERNAME)
SELECT DISTINCT
	Calificacion_Codigo, CEILING(Calificacion_Cant_Estrellas/2),
	Calificacion_Descripcion, Publicacion_Cod,
	LOWER(Cli_Nombre) + LOWER(Cli_Apeliido)
FROM gd_esquema.Maestra
WHERE Calificacion_Codigo IS NOT NULL

SET IDENTITY_INSERT SALUDOS.CALIFICACIONES OFF;

GO

UPDATE SALUDOS.CALIFICACIONES
SET CALI_FECHA = TRAN_FECHA
FROM SALUDOS.TRANSACCIONES
WHERE TRAN_ADJUDICADA = 1
	AND CALIFICACIONES.PUBL_COD = TRANSACCIONES.PUBL_COD
	AND CALIFICACIONES.USUA_USERNAME = TRANSACCIONES.USUA_USERNAME


--Agregando roles Cliente y Empresa a los clientes y a las... empresas.
INSERT INTO SALUDOS.ROLESXUSUARIO(
	USUA_USERNAME, ROL_COD)
SELECT USUA_USERNAME, ROL_COD
FROM SALUDOS.USUARIOS, SALUDOS.ROLES
WHERE	USUA_TIPO = 'Cliente' AND ROL_NOMBRE = 'Cliente' OR
		USUA_TIPO = 'Empresa' AND ROL_NOMBRE = 'Empresa'
				

--Creaci�n de tabla Fecha, function y procedure
--para manejar la fecha del sistema.
CREATE TABLE SALUDOS.FECHA(
	hoy datetime
)
GO

CREATE FUNCTION SALUDOS.fechaActual()
RETURNS datetime
AS 
	BEGIN
	RETURN (SELECT TOP 1 * FROM SALUDOS.FECHA)
	END
GO

CREATE PROCEDURE SALUDOS.asignarFecha
	@fecha datetime
AS
	DELETE FROM SALUDOS.FECHA
	INSERT INTO SALUDOS.FECHA
		VALUES (@fecha)
GO
