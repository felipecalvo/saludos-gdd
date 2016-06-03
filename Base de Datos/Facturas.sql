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
