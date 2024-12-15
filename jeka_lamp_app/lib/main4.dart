import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Генерация плана питания',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NutritionPlanForm(),
    );
  }
}

class NutritionPlanForm extends StatefulWidget {
  const NutritionPlanForm({Key? key}) : super(key: key);

  @override
  _NutritionPlanFormState createState() => _NutritionPlanFormState();
}

class _NutritionPlanFormState extends State<NutritionPlanForm> {
  final _formKey = GlobalKey<FormState>();
  String? gender = 'Мужчина';
  String? goal = 'Набор массы';
  String? activityLevel = 'Средний';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Генерация плана питания'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Генерация плана питания',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Вес (кг):',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Только цифры
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите ваш вес';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Рост (см):',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите ваш рост';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Возраст:',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите ваш возраст';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(
                  labelText: 'Пол:',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Мужчина', child: Text('Мужчина')),
                  DropdownMenuItem(value: 'Женщина', child: Text('Женщина')),
                ],
                onChanged: (value) {
                  setState(() {
                    gender = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: goal,
                decoration: const InputDecoration(
                  labelText: 'Цель:',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Набор массы', child: Text('Набор массы')),
                  DropdownMenuItem(value: 'Похудение', child: Text('Похудение')),
                  DropdownMenuItem(value: 'Поддержание формы', child: Text('Поддержание формы')),
                ],
                onChanged: (value) {
                  setState(() {
                    goal = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: activityLevel,
                decoration: const InputDecoration(
                  labelText: 'Уровень физической активности:',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Низкий', child: Text('Низкий')),
                  DropdownMenuItem(value: 'Средний', child: Text('Средний')),
                  DropdownMenuItem(value: 'Высокий', child: Text('Высокий')),
                ],
                onChanged: (value) {
                  setState(() {
                    activityLevel = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Пожелания:',
                  hintText: 'Например, без глютена',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('План питания создается...')),
                    );
                  }
                },
                child: const Text('Создать план питания'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
