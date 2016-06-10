--10. Consultas de facturas realizadas al vendedor.
--Esta funcionalidad permite listar todas las facturas realizadas a un usuario vendedor,
--ya sean por comisi�n de publicaci�n como ventas y env�os.
--Ser� necesario que se implementen una serie de filtros, como ser:
--intervalo de fechas, intervalos de importe, buscador por contenido de detalles de factura, a qui�n est� dirigida.  
--Dichos resultados deber�n listarse en una grilla, la cual deber� estar paginada.

CREATE FUNCTION SALUDOS.cantidadDeFacturas(
	@fechaInicio datetime, @fechaFinalizacion datetime,
	@codigoPublicacion numeric(18,0), @codigoFactura numeric(18,0),
	@importeMinimo int, @importeMaximo int,
	@destinatario nvarchar(255))
RETURNS int AS
	BEGIN
		DECLARE @cuenta decimal
		
		SET @cuenta = (
			SELECT COUNT(*)
			FROM SALUDOS.FACTURAS
			WHERE	(@fechaInicio <= FACT_FECHA OR @fechaInicio IS NULL) AND
					(@fechaFinalizacion >= FACT_FECHA OR @fechaInicio IS NULL) AND
					(@codigoPublicacion = PUBL_COD OR @codigoPublicacion IS NULL) AND
					(@codigoFactura = FACT_COD OR @codigoFactura IS NULL) AND
					(@importeMinimo <= FACT_TOTAL OR @importeMinimo IS NULL) AND
					(@importeMaximo >= FACT_TOTAL OR @importeMaximo IS NULL) AND
					(@destinatario = USUA_USERNAME OR @destinatario IS NULL)
		)

		SET @cuenta = CEILING(@cuenta / 10)

		RETURN CONVERT(int, @cuenta)

	END
GO

CREATE FUNCTION SALUDOS.facturasRealizadasAlVendedor(
	@fechaInicio datetime, @fechaFinalizacion datetime,
	@codigoPublicacion numeric(18,0), @codigoFactura numeric(18,0),
	@importeMinimo int, @importeMaximo int,
	@destinatario nvarchar(255))
RETURNS @facturas TABLE (	C�digo_Factura numeric(18,0), C�digo_Publicaci�n numeric(18,0),
							Usuario nvarchar(255), Total numeric(18,2), Fecha datetime		) AS
	BEGIN
		INSERT @facturas
			SELECT FACT_COD, PUBL_COD, USUA_USERNAME, FACT_TOTAL, FACT_FECHA
			FROM SALUDOS.FACTURAS
			WHERE	(@fechaInicio <= FACT_FECHA OR @fechaInicio IS NULL) AND
					(@fechaFinalizacion >= FACT_FECHA OR @fechaInicio IS NULL) AND
					(@codigoPublicacion = PUBL_COD OR @codigoPublicacion IS NULL) AND
					(@codigoFactura = FACT_COD OR @codigoFactura IS NULL) AND
					(@importeMinimo <= FACT_TOTAL OR @importeMinimo IS NULL) AND
					(@importeMaximo >= FACT_TOTAL OR @importeMaximo IS NULL) AND
					(@destinatario = USUA_USERNAME OR @destinatario IS NULL)
			ORDER BY FACT_FECHA DESC
		RETURN;
	END
GO

CREATE PROCEDURE SALUDOS.facturarPublicacion
	@codPublicacion numeric(18,0)
AS
	DECLARE @comisionPublicacion numeric(18,2)

	SET @comisionPublicacion =	(SELECT VISI_COMISION_PUBLICACION
								FROM SALUDOS.VISIBILIDADES
								WHERE VISI_COD = (	SELECT VISI_COD
													FROM SALUDOS.PUBLICACIONES
													WHERE PUBL_COD = @codPublicacion)
								)
	
	INSERT INTO SALUDOS.FACTURAS(
	FACT_FECHA, FACT_TOTAL, PUBL_COD, USUA_USERNAME)

	VALUES(
	saludos.fechaActual(), @comisionPublicacion, @codPublicacion,

	(SELECT USUA_USERNAME
	FROM SALUDOS.PUBLICACIONES
	WHERE PUBL_COD = @codPublicacion)
	)

	DECLARE @codFactura numeric(18,0)
	SET @codFactura = SCOPE_IDENTITY()

	INSERT INTO SALUDOS.ITEMS(
	ITEM_IMPORTE, ITEM_CANTIDAD,
	ITEM_DESCRIPCION, FACT_COD)

	VALUES(
	@comisionPublicacion, 1,
	'Comisi�n por Publicaci�n', @codFactura
	)

GO

CREATE PROCEDURE SALUDOS.facturarCompra
	@codPublicacion numeric(18,0),
	@cantidadComprada numeric(18,0),
	@precio numeric(18,2)
AS
	DECLARE @comisionVenta numeric(18,2)
	SET @comisionVenta =	(SELECT VISI_COMISION_VENTA
							FROM SALUDOS.VISIBILIDADES
							WHERE VISI_COD = (	SELECT VISI_COD
												FROM SALUDOS.PUBLICACIONES
												WHERE PUBL_COD = @codPublicacion)
											 )
	
	INSERT INTO SALUDOS.FACTURAS(
	FACT_FECHA, FACT_TOTAL, PUBL_COD, USUA_USERNAME)

	VALUES(
	saludos.fechaActual(), @comisionVenta * @cantidadComprada * @precio, @codPublicacion,

	(SELECT USUA_USERNAME
	FROM SALUDOS.PUBLICACIONES
	WHERE PUBL_COD = @codPublicacion)
	)

	DECLARE @codFactura numeric(18,0)
	SET @codFactura = SCOPE_IDENTITY()

	INSERT INTO SALUDOS.ITEMS(
	ITEM_IMPORTE, ITEM_CANTIDAD,
	ITEM_DESCRIPCION, FACT_COD)

	VALUES(
	@comisionVenta * @cantidadComprada * @precio, @cantidadComprada,
	'Comisi�n por Venta', @codFactura
	)

GO

CREATE PROCEDURE SALUDOS.facturarCompraYEnvio
	@codPublicacion numeric(18,0),
	@cantidadComprada numeric(18,0),
	@precio numeric(18,2)
AS
	DECLARE @comisionVenta numeric(18,2)
	SET @comisionVenta =	(SELECT VISI_COMISION_VENTA
							FROM SALUDOS.VISIBILIDADES
							WHERE VISI_COD = (	SELECT VISI_COD
												FROM SALUDOS.PUBLICACIONES
												WHERE PUBL_COD = @codPublicacion)
											 )
	DECLARE @comisionEnvio numeric(18,2)
	SET @comisionEnvio =	(SELECT VISI_COMISION_ENVIO
							FROM SALUDOS.VISIBILIDADES
							WHERE VISI_COD = (	SELECT VISI_COD
												FROM SALUDOS.PUBLICACIONES
												WHERE PUBL_COD = @codPublicacion)
											 )

	INSERT INTO SALUDOS.FACTURAS(
	FACT_FECHA, FACT_TOTAL, PUBL_COD, USUA_USERNAME)

	VALUES(
	saludos.fechaActual(), (@comisionVenta * @cantidadComprada * @precio) + @comisionEnvio, @codPublicacion,

	(SELECT USUA_USERNAME
	FROM SALUDOS.PUBLICACIONES
	WHERE PUBL_COD = @codPublicacion)
	)

	DECLARE @codFactura numeric(18,0)
	SET @codFactura = SCOPE_IDENTITY()

	INSERT INTO SALUDOS.ITEMS(
	ITEM_IMPORTE, ITEM_CANTIDAD,
	ITEM_DESCRIPCION, FACT_COD)

	VALUES(
	@comisionVenta * @cantidadComprada * @precio, @cantidadComprada,
	'Comisi�n por Venta', @codFactura
	)

	INSERT INTO SALUDOS.ITEMS(
	ITEM_IMPORTE, ITEM_CANTIDAD,
	ITEM_DESCRIPCION, FACT_COD)

	VALUES(
	@comisionEnvio, 1,
	'Comisi�n por Env�o', @codFactura
	)

GO
