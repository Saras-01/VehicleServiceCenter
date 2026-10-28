using Microsoft.Data.SqlClient;
using VehicleServiceCenter.Helpers;
using VehicleServiceCenter.Models;

namespace VehicleServiceCenter.Repositories;

public class CustomerRepository
{
    public void AddCustomer(Customer customer)
    {
        const string query = """
INSERT INTO Customers (FullName, Phone, Email, Address)
VALUES (@FullName, @Phone, @Email, @Address);
""";
    using SqlConnection connection = DatabaseHelper.CreateConnection();
        using SqlCommand command = new SqlCommand(query, connection);

        command.Parameters.AddWithValue("@FullName", customer.FullName);
        command.Parameters.AddWithValue("@Phone", customer.Phone);
        command.Parameters.AddWithValue("@Email", (object?)customer.Email ?? DBNull.Value);
        command.Parameters.AddWithValue("@Address", (object?)customer.Address ?? DBNull.Value);

        connection.Open();
        command.ExecuteNonQuery();
    }

    public List<Customer> GetAllCustomers()
    {
        const string query = """
        SELECT CustomerId, FullName, Phone, Email, Address, CreatedAt, IsActive
        FROM Customers
        ORDER BY CustomerId;
        """;

        List<Customer> customers = new();

        using SqlConnection connection = DatabaseHelper.CreateConnection();
        using SqlCommand command = new SqlCommand(query, connection);

        connection.Open();

        using SqlDataReader reader = command.ExecuteReader();

        while (reader.Read())
        {
            customers.Add(new Customer
            {
                CustomerId = reader.GetInt32(reader.GetOrdinal("CustomerId")),
                FullName = reader.GetString(reader.GetOrdinal("FullName")),
                Phone = reader.GetString(reader.GetOrdinal("Phone")),
                Email = reader.IsDBNull(reader.GetOrdinal("Email"))
                    ? null
                    : reader.GetString(reader.GetOrdinal("Email")),
                Address = reader.IsDBNull(reader.GetOrdinal("Address"))
                    ? null
                    : reader.GetString(reader.GetOrdinal("Address")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive"))
            });
        }

        return customers;
    }

    public Customer? GetCustomerById(int customerId)
    {
        const string query = """
        SELECT CustomerId, FullName, Phone, Email, Address, CreatedAt, IsActive
        FROM Customers
        WHERE CustomerId = @CustomerId;
        """;

        using SqlConnection connection = DatabaseHelper.CreateConnection();
        using SqlCommand command = new SqlCommand(query, connection);

        command.Parameters.AddWithValue("@CustomerId", customerId);

        connection.Open();

        using SqlDataReader reader = command.ExecuteReader();

        if (!reader.Read())
        {
            return null;
        }

        return new Customer
        {
            CustomerId = reader.GetInt32(reader.GetOrdinal("CustomerId")),
            FullName = reader.GetString(reader.GetOrdinal("FullName")),
            Phone = reader.GetString(reader.GetOrdinal("Phone")),
            Email = reader.IsDBNull(reader.GetOrdinal("Email"))
                ? null
                : reader.GetString(reader.GetOrdinal("Email")),
            Address = reader.IsDBNull(reader.GetOrdinal("Address"))
                ? null
                : reader.GetString(reader.GetOrdinal("Address")),
            CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
            IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive"))
        };
    }
}
