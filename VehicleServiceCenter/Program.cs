using Microsoft.Data.SqlClient;
using VehicleServiceCenter.Helpers;

Console.WriteLine("Testing Vehicle Service Center database connection...");

try
{
    using SqlConnection connection = DatabaseHelper.CreateConnection();

connection.Open();

    Console.WriteLine("Database connected successfully!");

    using SqlCommand command =
        new SqlCommand("SELECT DB_NAME()", connection);

    string? databaseName = command.ExecuteScalar()?.ToString();

    Console.WriteLine($"Connected Database: {databaseName}");
}
catch (Exception ex)
{
    Console.WriteLine("Database connection failed.");
    Console.WriteLine(ex.Message);
}

Console.WriteLine("Press any key to exit...");
Console.ReadKey();
