import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_products_app/providers/product_form_provider.dart';
import 'package:flutter_products_app/services/services.dart';
import 'package:flutter_products_app/ui/input_decorations.dart';
import 'package:flutter_products_app/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class ProductScreen extends StatelessWidget {
   
  const ProductScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

    final productService = Provider.of<ProductsService>(context);

    return ChangeNotifierProvider(
      create: ( _ ) => ProductFormProvider( productService.selectedProduct),
      child: _ProductScreenBody(productService: productService),
    );
  }
}

class _ProductScreenBody extends StatelessWidget {
  
  const _ProductScreenBody({
    Key? key,
    required this.productService,
  }) : super(key: key);

  final ProductsService productService;

  @override
  Widget build(BuildContext context) {

    final productForm = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            Stack(
              children: [
                ProductImage( url: productService.selectedProduct.picture),
                Positioned(
                  top: 50,
                  left: 20,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 40, color: Colors.white)
                  )
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: IconButton(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final PickedFile? pickedFile = await picker.getImage(
                        source: ImageSource.gallery,
                        imageQuality: 100
                      );

                      if( pickedFile == null ){
                        print('No selecciono nada');
                        return;
                      }

                      productService.updateSelectedProductImage(pickedFile.path);
                    },
                    icon: const Icon(Icons.camera_alt_outlined, size: 40, color: Colors.white)
                  )
                )
              ],
            ),
            _ProductForm(),
            SizedBox( height: 100 )
          ]
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton(
        child: productService.isSaving
        ? const CircularProgressIndicator( color: Colors.white )
        : const Icon(Icons.save_alt_outlined),
        onPressed: productService.isSaving
        ? null
        : () async {
          if ( !productForm.isValidForm() ) return ;
          
           await productService.saveOrCreateProduct(productForm.product);
        },
      ),
    );
  }
}

class _ProductForm extends StatelessWidget {

  const _ProductForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final productForm = Provider.of<ProductFormProvider>(context);
    final product = productForm.product;

    return Container(
      margin: EdgeInsets.symmetric( horizontal: 10),
      padding: EdgeInsets.symmetric( horizontal: 20),
      width: double.infinity,
      decoration: _buildBoxDecoration(),
      child: Form(
        key: productForm.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(children: [
          SizedBox(height: 10),

          TextFormField(
            initialValue: product.name,
            onChanged: ( value ) => product.name = value,
            validator:  (value ) {
              if( value == null || value.length < 1)
                return 'El nombre es obligatorio';
            },
            decoration: inputDecorations.authInputdecoration(
              labelText: 'Nombre:',
              hintText: 'Nombre del producto'
            ),
          ),

          SizedBox(height: 30),
          TextFormField(
            initialValue: '${product.price}',
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))
            ],
            onChanged: ( value ) => {
              if( double.tryParse(value) == null){
                product.price = 0
              } else {
                product.price = double.parse(value)
              }
            },
            keyboardType: TextInputType.number,
            decoration: inputDecorations.authInputdecoration(
              labelText: 'Precio:',
              hintText: '\$150'
            ),
          ),
          SizedBox(height: 30),

          SwitchListTile.adaptive(
            title: Text('Disponible'),
            activeColor: Colors.indigo,
            value: product.available,
            onChanged: productForm.updateAvailability
          ),

          SizedBox(height: 30),
        ],)),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only( bottomRight: Radius.circular(25), bottomLeft: Radius.circular(25)),
    boxShadow: [
      BoxShadow(
        color:  Colors.black.withOpacity(0.05),
        offset: Offset(0, 5),
        blurRadius: 5
      )
    ]
  );
}