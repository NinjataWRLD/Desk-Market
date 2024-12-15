using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using DeskMarket.Data.Data.Models;

namespace DeskMarket.Data.Data.Seeding
{
    public static class CategorySeeder
    {
        public static void Seed(IServiceProvider serviceProvider)
        {
            using (var context = new ApplicationDbContext(
                serviceProvider.GetRequiredService<DbContextOptions<ApplicationDbContext>>()))
            {
                if (context.Categories.Any())
                {
                    return;
                }

                context.Categories.AddRange(
                    new Category { Name = "Laptops" },
                    new Category { Name = "Workstations" },
                    new Category { Name = "Accessories" },
                    new Category { Name = "Desktops" },
                    new Category { Name = "Monitors" }
                );

                context.SaveChanges();
            }
        }
    }
}