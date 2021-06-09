**Checkout the jaguar_serializer readme** : https://pub.dartlang.org/packages/jaguar_serializer#-readme-tab-

**Anytime you see _pub_ replace with _flutter packages pub_**

**Step 1. Install the jaguar cli**

    flutter packages pub global activate jaguar_serializer_cli
    
    Note: After the Install step, add it to your enviroment path.
	ex:  C:\Users\<USERNAME>\AppData\Roaming\Pub\Cache\bin

**Step 2. To build all the models:**

	flutter packages pub run build_runner build

**Step 2 (Optional): To trigger rebuild with watch:**

	flutter packages pub run build_runner watch

**Step 3: To use a model in normal code**

	final userSerializer = new UserJsonSerializer();

	User user = userSerializer.fromMap(<KeyValueMap>);

	ex:
		User user = userSerializer.fromMap({
		'name': 'John',
		'age': 25
		});