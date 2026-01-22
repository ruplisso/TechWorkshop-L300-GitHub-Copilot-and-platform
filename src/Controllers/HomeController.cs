using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ZavaStorefront.Models;
using ZavaStorefront.Services;

namespace ZavaStorefront.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    private readonly ProductService _productService;
    private readonly CartService _cartService;

    public HomeController(ILogger<HomeController> logger, ProductService productService, CartService cartService)
    {
        _logger = logger;
        _productService = productService;
        _cartService = cartService;
    }

    public IActionResult Index(decimal? minPrice, decimal? maxPrice)
    {
        _logger.LogInformation("Loading products page with filters: minPrice={MinPrice}, maxPrice={MaxPrice}", minPrice, maxPrice);
        
        var products = _productService.GetFilteredProducts(minPrice, maxPrice);
        var priceRange = _productService.GetPriceRange();

        var viewModel = new ProductListViewModel
        {
            Products = products,
            MinPrice = minPrice,
            MaxPrice = maxPrice,
            PriceRangeMin = priceRange.Min,
            PriceRangeMax = priceRange.Max
        };

        return View(viewModel);
    }

    [HttpPost]
    public IActionResult AddToCart(int productId)
    {
        var product = _productService.GetProductById(productId);
        if (product != null)
        {
            _logger.LogInformation("Adding product {ProductId} ({ProductName}) to cart", productId, product.Name);
            _cartService.AddToCart(productId);
        }
        else
        {
            _logger.LogWarning("Attempted to add non-existent product {ProductId} to cart", productId);
        }

        return RedirectToAction("Index");
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
