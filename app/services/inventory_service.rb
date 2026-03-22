class InventoryService
  class InsufficientStockError < StandardError; end

  def self.reserve!(inventory, quantity)
    raise InsufficientStockError, "Insufficient stock for #{inventory.product.name}" unless inventory.sufficient_stock?(quantity)

    inventory.with_lock do
      inventory.increment!(:reserved_stock, quantity)
    end
  end

  def self.confirm!(inventory, quantity)
    inventory.with_lock do
      inventory.decrement!(:reserved_stock, quantity)
      inventory.decrement!(:stock, quantity)
    end
  end

  def self.release!(inventory, quantity)
    inventory.with_lock do
      inventory.decrement!(:reserved_stock, quantity)
    end
  end
end
