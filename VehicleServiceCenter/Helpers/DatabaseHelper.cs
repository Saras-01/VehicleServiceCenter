using Microsoft.Data.SqlClient;

namespace VehicleServiceCenter.Helpers;

public static class DatabaseHelper
{
    private const string ConnectionString =
        @"Server=.\SQLEXPRESS;Database=VehicleServiceDB;" +
        @"Trusted_Connection=True;TrustServerCertificate=True;";

    public static SqlConnection CreateConnection()
        => new SqlConnection(ConnectionString);
}
