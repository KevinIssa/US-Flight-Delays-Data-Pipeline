USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Dim_Date_Passengers
    (
        [YEAR],
        [MONTH],
        [QUARTER]
    )
    SELECT DISTINCT TOP (1000)
        SP.[YEAR],
        SP.[MONTH],
        SP.[QUARTER]

    FROM StagingSilver.dbo.SegmentPassengers AS SP

    WHERE SP.[YEAR] IS NOT NULL
      AND SP.[MONTH] IS NOT NULL
      AND NOT EXISTS (
        SELECT 1
        FROM dbo.Dim_Date_Passengers AS DP
        WHERE DP.[YEAR] = SP.[YEAR]
          AND DP.[MONTH] = SP.[MONTH]
     )

    COMMIT TRANSACTION;
    PRINT 'Chargement Dim_Date_Passengers termine avec succes.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Erreur pendant le chargement de Dim_Date_Passengers :';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO


