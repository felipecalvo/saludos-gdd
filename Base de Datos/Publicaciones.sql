CREATE FUNCTION SALUDOS.mostrarPublicaciones(
	@descripcion nvarchar(255), @rubro nvarchar(255))
RETURNS @publicaciones TABLE (	C�digo numeric(18,0), Descripci�n nvarchar(255),
								Precio numeric(18,2), Rubro nvarchar(255),
								Tipo nvarchar(255), Env�o nvarchar(2)) AS
	BEGIN
		--Requisitos para mostrar una publicaci�n:
		--#El usuario debe estar habilitado,
		--#La descripci�n tiene que incluir el texto que se busca,
		--#La publicaci�n debe pertenecer al rubro pedido,
		--#La publicaci�n debe estar activa.

		INSERT @publicaciones
		SELECT	PUBL_COD, PUBL_DESCRIPCION, PUBL_PRECIO, RUBR_NOMBRE, TIPO_NOMBRE,
				CASE WHEN PUBL_PERMITE_ENVIO = 1 THEN 'S�' ELSE 'No' END
		FROM SALUDOS.PUBLICACIONES publ, SALUDOS.RUBROS rubr, SALUDOS.TIPOS tipo
		WHERE	1 = (	SELECT USUA_HABILITADO
						FROM SALUDOS.USUARIOS usua
						WHERE usua.USUA_USERNAME = publ.USUA_USERNAME) AND
				(PUBL_DESCRIPCION LIKE '%' + @descripcion + '%' OR @descripcion IS NULL) AND
				publ.RUBR_COD = rubr.RUBR_COD AND
				(publ.RUBR_COD = (	SELECT RUBR_COD
									FROM SALUDOS.RUBROS
									WHERE RUBR_NOMBRE = @rubro) OR @rubro IS NULL) AND
				publ.TIPO_COD =	tipo.TIPO_COD AND
				ESTA_COD = (	SELECT ESTA_COD
								FROM SALUDOS.ESTADOS
								WHERE ESTA_NOMBRE = 'Activa')
		ORDER BY VISI_COD
		RETURN;
	END
GO

CREATE FUNCTION SALUDOS.cantidadDePaginasPublicaciones(
	@descripcion nvarchar(255), @rubro nvarchar(255))
RETURNS int AS
	BEGIN
		
		DECLARE @cuenta decimal
		
		SET @cuenta = (
			SELECT COUNT(*)
			FROM SALUDOS.PUBLICACIONES publ, SALUDOS.RUBROS rubr, SALUDOS.TIPOS tipo
			WHERE	1 = (	SELECT USUA_HABILITADO
							FROM SALUDOS.USUARIOS usua
							WHERE usua.USUA_USERNAME = publ.USUA_USERNAME) AND
					(PUBL_DESCRIPCION LIKE '%' + @descripcion + '%' OR @descripcion IS NULL) AND
					publ.RUBR_COD = rubr.RUBR_COD AND
					(publ.RUBR_COD = (	SELECT RUBR_COD
										FROM SALUDOS.RUBROS
										WHERE RUBR_NOMBRE = @rubro) OR @rubro IS NULL) AND
					publ.TIPO_COD =	tipo.TIPO_COD AND
					ESTA_COD = (	SELECT ESTA_COD
									FROM SALUDOS.ESTADOS
									WHERE ESTA_NOMBRE = 'Activa')
		)

		SET @cuenta = CEILING(@cuenta / 10)
		RETURN CONVERT(int, @cuenta)
	END
GO

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

	UPDATE SALUDOS.PUBLICACIONES
	SET SALUDOS.PUBLICACIONES.ESTA_COD = @codFinalizada
	FROM 	(SELECT comp.PUBL_COD, PUBL_STOCK, SUM(COMP_CANTIDAD) AS COMP_ACTUALES, ESTA_COD
			FROM SALUDOS.COMPRAS comp, SALUDOS.PUBLICACIONES publ
			WHERE comp.PUBL_COD = publ.PUBL_COD AND COMP_FECHA <= SALUDOS.fechaActual() 
			GROUP BY comp.PUBL_COD, PUBL_STOCK, ESTA_COD) COMPRAS
	WHERE	COMPRAS.ESTA_COD = @codActiva AND
			COMPRAS.COMP_ACTUALES = COMPRAS.PUBL_STOCK AND
			COMPRAS.PUBL_COD = SALUDOS.PUBLICACIONES.PUBL_COD
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

	INSERT INTO SALUDOS.COMPRAS(
	COMP_CANTIDAD, COMP_FECHA, COMP_FORMA_PAGO, COMP_OPTA_ENVIO,
	COMP_PRECIO, PUBL_COD, USUA_USERNAME)

	SELECT DISTINCT
	1, OFER_FECHA, 'Efectivo', OFER_OPTA_ENVIO,
	OFER_OFERTA, t1.PUBL_COD, t1.USUA_USERNAME

	FROM SALUDOS.OFERTAS t1, SALUDOS.PUBLICACIONES publ
	WHERE	publ.PUBL_COD = t1.PUBL_COD AND
			TIPO_COD = @tipoSubasta AND
			ESTA_COD = @codFinalizada AND
			OFER_OFERTA = 	(SELECT MAX(OFER_OFERTA)
							FROM SALUDOS.OFERTAS t2
							WHERE t2.PUBL_COD = t1.PUBL_COD)
			AND NOT EXISTS (SELECT PUBL_COD
							FROM SALUDOS.COMPRAS comp
							WHERE comp.PUBL_COD = publ.PUBL_COD)

	EXEC SALUDOS.facturarSubastasAdjudicadas
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

	DECLARE @codPublicacion numeric(18,0)
	SET @codPublicacion = SCOPE_IDENTITY()

	DECLARE @usuarioNuevo bit
	SET @usuarioNuevo = (	SELECT USUA_NUEVO
							FROM SALUDOS.USUARIOS
							WHERE USUA_USERNAME = @usuario)

	IF (@visibilidad <> 'Gratis' AND @usuarioNuevo = 1)
		BEGIN
			EXEC SALUDOS.facturarPublicacionGratuita @codPublicacion

			UPDATE SALUDOS.USUARIOS
			SET USUA_NUEVO = 0
			WHERE USUA_USERNAME = @usuario
		END
	ELSE BEGIN
		EXEC SALUDOS.facturarPublicacion @codPublicacion
	END

GO

CREATE FUNCTION SALUDOS.stockActual(@codPublicacion numeric(18,0))
RETURNS int AS
	BEGIN
		DECLARE @cantidadComprada int
		
		SET @cantidadComprada = (
			SELECT SUM(COMP_CANTIDAD)
			FROM SALUDOS.COMPRAS
			WHERE	PUBL_COD = @codPublicacion AND
					COMP_FECHA <= SALUDOS.fechaActual()
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
	@cantidadComprada numeric(18,0),
	@usuario nvarchar(255),	
	@optaEnvio bit
AS
	INSERT INTO SALUDOS.COMPRAS(
	COMP_CANTIDAD, COMP_FECHA, COMP_FORMA_PAGO,
	COMP_PRECIO, PUBL_COD, USUA_USERNAME, COMP_OPTA_ENVIO)

	VALUES(
	@cantidadComprada, SALUDOS.fechaActual(), 'Efectivo',

	(SELECT PUBL_PRECIO
	FROM SALUDOS.PUBLICACIONES
	WHERE PUBL_COD = @codPublicacion),

	@codPublicacion, @usuario, @optaEnvio)

	IF SALUDOS.stockActual(@codPublicacion) = 0 BEGIN
		EXEC SALUDOS.cambiarEstadoPublicacion @codPublicacion, 'Finalizada'
	END

	DECLARE @precio numeric(18,2)
	SET @precio =	(SELECT PUBL_PRECIO
					FROM SALUDOS.PUBLICACIONES
					WHERE PUBL_COD = @codPublicacion)

	IF @optaEnvio = 1
		BEGIN
			EXEC SALUDOS.facturarCompraYEnvio @codPublicacion, @cantidadComprada, @precio
		END
	ELSE
		BEGIN
			EXEC SALUDOS.facturarCompra	@codPublicacion, @cantidadComprada, @precio
		END
GO

CREATE PROCEDURE SALUDOS.ofertar
	@codPublicacion numeric(18,0),
	@oferta numeric(18,2),
	@usuario nvarchar(255),
	@optaEnvio bit
AS
	INSERT INTO SALUDOS.OFERTAS(
	OFER_FECHA, OFER_OFERTA,
	PUBL_COD, USUA_USERNAME, OFER_OPTA_ENVIO)

	VALUES(
	SALUDOS.fechaActual(), @oferta,
	@codPublicacion, @usuario, @optaEnvio)
GO

CREATE FUNCTION SALUDOS.ultimaOferta(@codPublicacion numeric(18,0))
RETURNS numeric(18,2) AS
	BEGIN
		DECLARE @oferta numeric(18,2)
		
		SET @oferta = (
			SELECT MAX(OFER_OFERTA)
			FROM SALUDOS.OFERTAS
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

CREATE FUNCTION SALUDOS.filtrarPublicacionesParaCambioDeEstado(
	@descripcion nvarchar(255), @creador nvarchar(255), @estado nvarchar(255))
RETURNS @publicaciones TABLE (	C�digo numeric(18,0), Descripci�n nvarchar(255),
								Vendedor nvarchar(255), Estado nvarchar(255)) AS
	BEGIN
		INSERT @publicaciones
		SELECT PUBL_COD, PUBL_DESCRIPCION, USUA_USERNAME, ESTA_NOMBRE
		FROM SALUDOS.PUBLICACIONES, SALUDOS.ESTADOS esta
		WHERE	(USUA_USERNAME = @creador OR @creador IS NULL) AND
				(PUBL_DESCRIPCION LIKE '%' + @descripcion + '%' OR @descripcion IS NULL) AND
				(esta.ESTA_COD = (	SELECT ESTA_COD
									FROM SALUDOS.ESTADOS
									WHERE ESTA_NOMBRE = @estado) OR @estado IS NULL)
		ORDER BY PUBL_COD
		RETURN;
	END
GO

CREATE FUNCTION SALUDOS.detallesPublicacionCompraInmediata(@codigo numeric(18,0))
RETURNS @publicaciones TABLE (	Descripci�n nvarchar(255), Precio numeric(18,2), Rubro nvarchar(255),
								Stock numeric(18,0), Env�o bit, Vendedor nvarchar(255)) AS
	BEGIN
		INSERT @publicaciones
		SELECT PUBL_DESCRIPCION, PUBL_PRECIO, RUBR_NOMBRE, SALUDOS.stockActual(@codigo), PUBL_PERMITE_ENVIO, USUA_USERNAME
		FROM SALUDOS.PUBLICACIONES publ, SALUDOS.RUBROS rubr
		WHERE	PUBL_COD = @codigo AND
				publ.RUBR_COD = rubr.RUBR_COD
		RETURN;
	END
GO

CREATE FUNCTION SALUDOS.detallesPublicacionSubasta(@codigo numeric(18,0))
RETURNS @publicaciones TABLE (	Descripci�n nvarchar(255), Precio numeric(18,2), Rubro nvarchar(255),
								�ltima_Oferta numeric(18,2), Env�o bit, Vendedor nvarchar(255)) AS
	BEGIN
		INSERT @publicaciones
		SELECT PUBL_DESCRIPCION, PUBL_PRECIO, RUBR_NOMBRE, SALUDOS.ultimaOferta(@codigo), PUBL_PERMITE_ENVIO, USUA_USERNAME
		FROM SALUDOS.PUBLICACIONES publ, SALUDOS.RUBROS rubr
		WHERE	PUBL_COD = @codigo AND
				publ.RUBR_COD = rubr.RUBR_COD
		RETURN;
	END
GO

