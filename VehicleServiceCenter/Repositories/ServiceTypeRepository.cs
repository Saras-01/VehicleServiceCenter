using Microsoft.Data.SqlClient;
using System.Data;
using VehicleServiceCenter.Helpers;
using VehicleServiceCenter.Models;

namespace VehicleServiceCenter.Repositories;

public class ServiceTypeRepository
{
    public async Task<int> AddAsync(ServiceType serviceType)
    {
        const string sql = @"
            INSERT INTO ServiceTypes
                (ServiceName, Description, StandardPrice, EstimatedMinutes)
            VALUES
                (@ServiceName, @Description, @StandardPrice, @EstimatedMinutes);
            SELECT CAST(SCOPE_IDENTITY() AS INT);";

        await using SqlConnection connection = DatabaseHelper.CreateConnection();
        await using SqlCommand command = new(sql, connection);

        command.Parameters.Add("@ServiceName", SqlDbType.NVarChar, 100)
            .Value = serviceType.ServiceName;
        command.Parameters.Add("@Description", SqlDbType.NVarChar, 300)
            .Value = (object?)serviceType.Description ?? DBNull.Value;
        command.Parameters.Add("@StandardPrice", SqlDbType.Decimal).Value =
            serviceType.StandardPrice;
        command.Parameters["@StandardPrice"].Precision = 10;
        command.Parameters["@StandardPrice"].Scale = 2;
        command.Parameters.Add("@EstimatedMinutes", SqlDbType.Int)
            .Value = serviceType.EstimatedMinutes;

        await connection.OpenAsync();
        object? result = await command.ExecuteScalarAsync();
        return Convert.ToInt32(result);
    }
}
