namespace VehicleServiceCenter.Models;

public class ServiceType
{
    public int ServiceTypeId { get; set; }

public string ServiceName { get; set; } = string.Empty;

    public string? Description { get; set; }

    public decimal StandardPrice { get; set; }

    public int EstimatedMinutes { get; set; }

    public bool IsActive { get; set; } = true;
}
