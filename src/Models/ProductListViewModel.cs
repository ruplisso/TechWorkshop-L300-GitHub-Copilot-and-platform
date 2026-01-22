namespace ZavaStorefront.Models
{
    public class ProductListViewModel
    {
        public List<Product> Products { get; set; } = new List<Product>();
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public decimal PriceRangeMin { get; set; }
        public decimal PriceRangeMax { get; set; }
    }
}
