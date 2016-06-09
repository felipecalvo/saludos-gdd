CREATE PROCEDURE SALUDOS.actualizarEstadosDePublicaciones AS
	DECLARE @fecha datetime
	DECLARE @codActiva int
	DECLARE @codFinalizada int
	
	SET @fecha = SALUDOS.fechaActual()

	SET @codActiva = (	SELECT ESTA_COD 
						FROM SALUDOS.ESTADOS
						WHERE ESTA_NOMBRE = 'Activa')
	
	SET @codFinalizada = (	SELECT ESTA_COD 
							FROM SALUDOS.ESTADOS
							WHERE ESTA_NOMBRE = 'Finalizada')

	UPDATE SALUDOS.PUBLICACIONES
	SET SALUDOS.PUBLICACIONES.ESTA_COD = @codActiva
	WHERE	PUBL_INICIO <= @fecha AND
			PUBL_FINALIZACION > @fecha AND
			ESTA_COD IN (@codActiva, @codFinalizada)
			
	UPDATE SALUDOS.PUBLICACIONES
	SET SALUDOS.PUBLICACIONES.ESTA_COD = @codFinalizada
	WHERE  (PUBL_INICIO > @fecha OR
			PUBL_FINALIZACION <= @fecha) AND
			ESTA_COD IN (@codActiva, @codFinalizada)
GO

CREATE PROCEDURE SALUDOS.adjudicarSubastas AS
	DECLARE @tipoSubasta int

	SET @tipoSubasta = (SELECT TIPO_COD
						FROM SALUDOS.TIPOS
						WHERE TIPO_NOMBRE = 'Subasta')
	
	DECLARE @codFinalizada int
	SET @codFinalizada = (	SELECT ESTA_COD 
							FROM SALUDOS.ESTADOS
							WHERE ESTA_NOMBRE = 'Finalizada')

	UPDATE SALUDOS.TRANSACCIONES
	SET SALUDOS.TRANSACCIONES.TRAN_ADJUDICADA = 1
	FROM (
		SELECT PUBL_COD
		FROM SALUDOS.PUBLICACIONES
		WHERE ESTA_COD = @codFinalizada) publ
	WHERE	TRAN_ADJUDICADA = 0 AND
			TIPO_COD = @tipoSubasta AND
			TRAN_PRECIO = (	SELECT COALESCE(MAX(TRAN_PRECIO), 0)
							FROM SALUDOS.TRANSACCIONES trns
							WHERE trns.PUBL_COD = SALUDOS.TRANSACCIONES.PUBL_COD) AND
			publ.PUBL_COD = SALUDOS.TRANSACCIONES.PUBL_COD
GO

CREATE PROCEDURE SALUDOS.crearPublicacion
	@usuario nvarchar(255),
	@tipo nvarchar(255),
	@descripcion nvarchar(255),
	@stock numeric(18,0),
	@precio numeric(18,2),
	@rubro nvarchar(255),
	@estado nvarchar(255),
	@preguntas bit,
	@visibilidad nvarchar(255),
	@envio bit
AS
	INSERT INTO SALUDOS.PUBLICACIONES(
	USUA_USERNAME, TIPO_COD, PUBL_DESCRIPCION,
	PUBL_STOCK, PUBL_PRECIO, RUBR_COD, ESTA_COD,
	PUBL_PREGUNTAS,	VISI_COD, PUBL_PERMITE_ENVIO,
	PUBL_INICIO, PUBL_FINALIZACION)

	VALUES(
	(SELECT USUA_USERNAME
	FROM SALUDOS.USUARIOS
	WHERE USUA_USERNAME = @usuario),

	(SELECT TIPO_COD
	FROM SALUDOS.TIPOS
	WHERE TIPO_NOMBRE = @tipo),

	@descripcion, @stock, @precio,

	(SELECT RUBR_COD
	FROM SALUDOS.RUBROS
	WHERE RUBR_NOMBRE = @rubro),

	(SELECT ESTA_COD
	FROM SALUDOS.ESTADOS
	WHERE ESTA_NOMBRE = @estado),

	@preguntas,

	(SELECT VISI_COD
	FROM SALUDOS.VISIBILIDADES
	WHERE VISI_DESCRIPCION = @visibilidad),

	@envio,

	(SELECT SALUDOS.fechaActual()),

	DATEADD(day, 7, SALUDOS.fechaActual())
	)
GO

CREATE FUNCTION SALUDOS.stockActual(@codPublicacion numeric(18,0))
RETURNS int AS
	BEGIN
		DECLARE @cantidadComprada int
		
		SET @cantidadComprada = (
			SELECT SUM(TRAN_CANTIDAD_COMPRADA)
			FROM SALUDOS.TRANSACCIONES
			WHERE	PUBL_COD = @codPublicacion AND
					TRAN_FECHA <= SALUDOS.fechaActual()
		)

		IF @cantidadComprada IS NULL
			SET @cantidadComprada = 0

		DECLARE @stockInicial int
		SET @stockInicial = (
			SELECT PUBL_STOCK
			FROM SALUDOS.PUBLICACIONES
			WHERE PUBL_COD = @codPublicacion
		)

		RETURN (@stockInicial - @cantidadComprada)
	END
GO

CREATE PROCEDURE SALUDOS.comprar
	@codPublicacion numeric(18,0),
	@cantidadComprada int,
	@usuario nvarchar(255)
AS
	INSERT INTO SALUDOS.TRANSACCIONES(
	PUBL_COD, TIPO_COD, TRAN_ADJUDICADA,
	TRAN_CANTIDAD_COMPRADA, TRAN_FECHA,
	TRAN_FORMA_PAGO, TRAN_PRECIO, USUA_USERNAME)

	VALUES(
	@codPublicacion,
	
	(SELECT TIPO_COD
	FROM SALUDOS.TIPOS
	WHERE TIPO_NOMBRE = 'Compra Inmediata'),
	
	1, @cantidadComprada,
	SALUDOS.fechaActual(), 'Efectivo',

	(SELECT PUBL_PRECIO
	FROM SALUDOS.PUBLICACIONES
	WHERE PUBL_COD = @codPublicacion),

	@usuario
	)
GO

CREATE PROCEDURE SALUDOS.ofertar
	@codPublicacion numeric(18,0),
	@oferta numeric(18,2),
	@usuario nvarchar(255)
AS
	INSERT INTO SALUDOS.TRANSACCIONES(
	PUBL_COD, TIPO_COD, TRAN_ADJUDICADA,
	TRAN_CANTIDAD_COMPRADA, TRAN_FECHA,
	TRAN_FORMA_PAGO, TRAN_PRECIO, USUA_USERNAME)

	VALUES(
	@codPublicacion,
	
	(SELECT TIPO_COD
	FROM SALUDOS.TIPOS
	WHERE TIPO_NOMBRE = 'Subasta'),
	
	0, 1,
	SALUDOS.fechaActual(), 'Efectivo',

	@oferta, @usuario
	)
GO

CREATE FUNCTION SALUDOS.ultimaOferta(@codPublicacion numeric(18,0))
RETURNS numeric(18,2) AS
	BEGIN
		DECLARE @oferta numeric(18,2)
		
		SET @oferta = (
			SELECT MAX(TRAN_PRECIO)
			FROM SALUDOS.TRANSACCIONES
			WHERE PUBL_COD = @codPublicacion
		)

		IF @oferta IS NULL 
			SET @oferta = 0.00
		
		RETURN @oferta

	END

GO

CREATE PROCEDURE SALUDOS.cambiarEstadoPublicacion
	@codPublicacion numeric(18,0),
	@nuevoEstado nvarchar(255)
AS
	DECLARE @codEstado int 
	SET @codEstado	= (	SELECT ESTA_COD
						FROM SALUDOS.ESTADOS
						WHERE ESTA_NOMBRE = @nuevoEstado)

	UPDATE SALUDOS.PUBLICACIONES
	SET SALUDOS.PUBLICACIONES.ESTA_COD = @codEstado
	WHERE PUBL_COD = @codPublicacion
GO
