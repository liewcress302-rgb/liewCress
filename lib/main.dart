import 'package:flutter/material.dart';

void main() {
  runApp(const ShopApp());
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '简易购物系统',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: const Color(0xFFF4F7F8),
        useMaterial3: true,
      ),
      home: const ShopStateScope(
        child: MainShell(),
      ),
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.category,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final IconData icon;
  final String category;
}

class CartItem {
  CartItem({
    required this.product,
    this.quantity = 1,
  });

  final Product product;
  int quantity;

  double get subtotal => product.price * quantity;
}

class ShopController extends ChangeNotifier {
  final List<Product> products = const [
    Product(
      id: 1,
      name: '无线耳机',
      description: '日常通勤和运动都适合的轻量耳机',
      price: 299,
      icon: Icons.headphones,
      category: '数码',
    ),
    Product(
      id: 2,
      name: '保温水杯',
      description: '316 不锈钢内胆，保温持久',
      price: 89,
      icon: Icons.local_drink,
      category: '生活',
    ),
    Product(
      id: 3,
      name: '办公键盘',
      description: '静音按键，适合长时间办公输入',
      price: 199,
      icon: Icons.keyboard,
      category: '办公',
    ),
    Product(
      id: 4,
      name: '极简背包',
      description: '大容量分区设计，适合通勤短途',
      price: 159,
      icon: Icons.backpack,
      category: '出行',
    ),
    Product(
      id: 5,
      name: '护眼台灯',
      description: '三档亮度调节，阅读更舒适',
      price: 129,
      icon: Icons.light,
      category: '家居',
    ),
    Product(
      id: 6,
      name: '便携音箱',
      description: '体积小巧，适合宿舍与露营',
      price: 249,
      icon: Icons.speaker,
      category: '数码',
    ),
  ];

  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get totalQuantity =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.subtotal);

  double get shippingFee => _cartItems.isEmpty ? 0 : 12;

  double get discount => subtotal >= 500 ? 30 : 0;

  double get total => subtotal + shippingFee - discount;

  void addToCart(Product product) {
    final existingIndex =
        _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex == -1) {
      _cartItems.add(CartItem(product: product));
    } else {
      _cartItems[existingIndex].quantity++;
    }
    notifyListeners();
  }

  void increaseQuantity(Product product) {
    final item = _cartItems.firstWhere((entry) => entry.product.id == product.id);
    item.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(Product product) {
    final item = _cartItems.firstWhere((entry) => entry.product.id == product.id);
    if (item.quantity == 1) {
      _cartItems.remove(item);
    } else {
      item.quantity--;
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

class ShopStateScope extends StatefulWidget {
  const ShopStateScope({
    super.key,
    required this.child,
  });

  final Widget child;

  static ShopController of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_ShopControllerInherited>();
    assert(inherited != null, 'ShopStateScope not found in widget tree.');
    return inherited!.controller;
  }

  @override
  State<ShopStateScope> createState() => _ShopStateScopeState();
}

class _ShopStateScopeState extends State<ShopStateScope> {
  late final ShopController controller;

  @override
  void initState() {
    super.initState();
    controller = ShopController();
    controller.addListener(_handleUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_handleUpdate);
    controller.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _ShopControllerInherited(
      controller: controller,
      child: widget.child,
    );
  }
}

class _ShopControllerInherited extends InheritedWidget {
  const _ShopControllerInherited({
    required this.controller,
    required super.child,
  });

  final ShopController controller;

  @override
  bool updateShouldNotify(_ShopControllerInherited oldWidget) {
    return true;
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = ShopStateScope.of(context);
    final pages = [
      HomePage(
        onBrowseProducts: () => setState(() => currentIndex = 1),
        onViewCart: () => setState(() => currentIndex = 2),
      ),
      const ProductListPage(),
      const CartPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('简易购物系统'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (controller.totalQuantity > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${controller.totalQuantity}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() => currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '主页',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: '商品',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: '购物车',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onBrowseProducts,
    required this.onViewCart,
  });

  final VoidCallback onBrowseProducts;
  final VoidCallback onViewCart;

  @override
  Widget build(BuildContext context) {
    final controller = ShopStateScope.of(context);
    final featuredProducts = controller.products.take(3).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00796B), Color(0xFF26A69A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '欢迎来到掌上小店',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '这里提供一个简单清晰的购物流程示例，适合练习 Flutter 页面与状态管理。',
                style: TextStyle(color: Colors.white, height: 1.5),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: onBrowseProducts,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF00796B),
                    ),
                    child: const Text('进入商品列表'),
                  ),
                  OutlinedButton(
                    onPressed: onViewCart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                    ),
                    child: const Text('查看购物车'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: '商品数量',
                value: '${controller.products.length}',
                icon: Icons.inventory_2_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: '购物车件数',
                value: '${controller.totalQuantity}',
                icon: Icons.shopping_bag_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          '推荐商品',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...featuredProducts.map(
          (product) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFE0F2F1),
                child: Icon(product.icon, color: const Color(0xFF00796B)),
              ),
              title: Text(product.name),
              subtitle: Text(product.description),
              trailing: Text('¥${product.price.toStringAsFixed(0)}'),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ShopStateScope.of(context);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: controller.products.length,
      itemBuilder: (context, index) {
        final product = controller.products[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    product.icon,
                    size: 40,
                    color: const Color(0xFF00796B),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product.category,
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(height: 1.4),
                ),
                const Spacer(),
                Text(
                  '¥${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      controller.addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} 已加入购物车'),
                          duration: const Duration(milliseconds: 900),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('加入购物车'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ShopStateScope.of(context);

    if (controller.cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.remove_shopping_cart, size: 72, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              '购物车还是空的',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('先去商品列表挑选一些喜欢的商品吧'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.cartItems.length,
            itemBuilder: (context, index) {
              final item = controller.cartItems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFFE0F2F1),
                    child: Icon(item.product.icon, color: const Color(0xFF00796B)),
                  ),
                  title: Text(item.product.name),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '单价 ¥${item.product.price.toStringAsFixed(0)}',
                    ),
                  ),
                  trailing: SizedBox(
                    width: 110,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '¥${item.subtotal.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _QuantityButton(
                              icon: Icons.remove,
                              onTap: () => controller.decreaseQuantity(item.product),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text('${item.quantity}'),
                            ),
                            _QuantityButton(
                              icon: Icons.add,
                              onTap: () => controller.increaseQuantity(item.product),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _PriceRow(label: '商品金额', value: controller.subtotal),
              _PriceRow(label: '运费', value: controller.shippingFee),
              _PriceRow(label: '满减优惠', value: -controller.discount),
              const Divider(height: 24),
              _PriceRow(
                label: '合计',
                value: controller.total,
                isTotal: true,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CheckoutPage(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('去结账'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ShopStateScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('结账页面')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '收货信息',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '收货人姓名',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? '请输入姓名' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: '联系电话',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().length < 6 ? '请输入有效电话' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '收货地址',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? '请输入详细地址'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '订单摘要',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...controller.cartItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('${item.product.name} x ${item.quantity}'),
                          ),
                          Text('¥${item.subtotal.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  _PriceRow(label: '商品金额', value: controller.subtotal),
                  _PriceRow(label: '运费', value: controller.shippingFee),
                  _PriceRow(label: '优惠', value: -controller.discount),
                  _PriceRow(
                    label: '应付总额',
                    value: controller.total,
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) {
                return;
              }

              showDialog<void>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('下单成功'),
                    content: Text(
                      '${_nameController.text}，你的订单已提交，订单金额为 ¥${controller.total.toStringAsFixed(0)}。',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          controller.clearCart();
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('完成'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('提交订单'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2F1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF00796B)),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final double value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isTotal ? 18 : 15,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      color: isTotal ? Colors.teal.shade700 : Colors.black87,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(
            '${value < 0 ? '-' : ''}¥${value.abs().toStringAsFixed(0)}',
            style: style,
          ),
        ],
      ),
    );
  }
}
