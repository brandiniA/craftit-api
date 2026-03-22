# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

if Rails.env.development?
  puts "Clearing existing data..."
  [ OrderItem, Order, Payment, Shipment, CartItem, WishlistItem, Review, Inventory, ProductImage, Product, Category,
    Address, CustomerProfile ].each(&:destroy_all)
end

puts "Seeding categories..."
figures = Category.create!(name: "Figures", description: "Action figures and collectibles")
anime = Category.create!(name: "Anime", parent_category: figures, description: "Anime figures")
manga = Category.create!(name: "Manga", description: "Manga books and volumes")
board_games = Category.create!(name: "Board Games", description: "Tabletop and board games")

puts "Seeding products..."
products = [
  { name: "Goku Ultra Instinct Figure", price: 899.99, sku: "FIG-DBZ-001", category: anime,
    description: "High-quality Dragon Ball figure" },
  { name: "Naruto Sage Mode Figure", price: 749.99, sku: "FIG-NAR-001", category: anime,
    description: "Detailed Naruto Shippuden figure" },
  { name: "One Piece Vol. 1", price: 129.99, sku: "MNG-OP-001", category: manga,
    description: "First volume of One Piece manga" },
  { name: "Catan Board Game", price: 599.99, sku: "BRD-CTN-001", category: board_games,
    description: "Classic strategy board game" },
  { name: "Attack on Titan Levi Figure", price: 1299.99, compare_at_price: 1599.99, sku: "FIG-AOT-001",
    category: anime, description: "Premium Levi Ackerman figure" }
]

products.each do |attrs|
  product = Product.create!(attrs)
  Inventory.create!(product: product, stock: rand(10..50), low_stock_threshold: 5)
  ProductImage.create!(product: product, url: "https://placehold.co/600x600?text=#{product.slug}", alt_text: product.name,
    position: 0)
end

puts "Seeding customer profile..."
profile = CustomerProfile.create!(auth_user_id: "seed-user-001", phone: "+52 55 1234 5678")
Address.create!(customer_profile: profile, label: "Home", street: "Av. Reforma 123", city: "CDMX",
  state: "Ciudad de México", zip_code: "06600", country: "MX", is_default: true)

puts "Done! Created #{Category.count} categories, #{Product.count} products, #{Inventory.count} inventories."
