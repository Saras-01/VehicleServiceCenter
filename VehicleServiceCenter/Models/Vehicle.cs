namespace VehicleServiceCenter.Models;

public class Vehicle
{
    public int VehicleId { get; set; }

public int CustomerId { get; set; }

    public string RegistrationNumber { get; set; } = string.Empty;

    public string Make { get; set; } = string.Empty;

    public string Model { get; set; } = string.Empty;

    public int ManufactureYear { get; set; }

    public string FuelType { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;
}

