import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}

// Pre-define the categories required by the application
final List<CategoryModel> appCategories = [
  const CategoryModel(
    id: 'OOP',
    title: 'OOP',
    icon: Icons.code,
    color: Color(0xFF4CAF50),
  ),
  const CategoryModel(
    id: 'DBMS',
    title: 'DBMS',
    icon: Icons.storage,
    color: Color(0xFF2196F3),
  ),
  const CategoryModel(
    id: 'Data Structures',
    title: 'Data Structures',
    icon: Icons.account_tree,
    color: Color(0xFFFF9800),
  ),
  const CategoryModel(
    id: 'Operating Systems',
    title: 'Operating Systems',
    icon: Icons.memory,
    color: Color(0xFFE91E63),
  ),
  const CategoryModel(
    id: 'Computer Networks',
    title: 'Computer Networks',
    icon: Icons.wifi,
    color: Color(0xFF9C27B0),
  ),
  const CategoryModel(
    id: 'Algorithms',
    title: 'Algorithms',
    icon: Icons.functions,
    color: Color(0xFFF44336),
  ),
  const CategoryModel(
    id: 'Software Engineering',
    title: 'Software Engineering',
    icon: Icons.engineering,
    color: Color(0xFF009688),
  ),
];
