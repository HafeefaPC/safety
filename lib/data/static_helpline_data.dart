import '../models/helpline_model.dart';

class StaticHelplineData {
  static const List<HelplineModel> helplines = [
    // Emergency Services
    HelplineModel(
      id: 'police',
      name: 'Police',
      number: '100',
      category: 'Emergency',
      description: 'Police emergency services',
      icon: '🚔',
    ),
    HelplineModel(
      id: 'ambulance',
      name: 'Ambulance',
      number: '102',
      category: 'Emergency',
      description: 'Medical emergency services',
      icon: '🚑',
    ),
    HelplineModel(
      id: 'fire',
      name: 'Fire Department',
      number: '101',
      category: 'Emergency',
      description: 'Fire emergency services',
      icon: '🚒',
    ),
    
    // Women's Safety
    HelplineModel(
      id: 'women_helpline',
      name: 'Women Helpline',
      number: '1091',
      category: 'Women Safety',
      description: 'Women safety and support',
      icon: '👩',
    ),
    HelplineModel(
      id: 'domestic_violence',
      name: 'Domestic Violence',
      number: '181',
      category: 'Women Safety',
      description: 'Domestic violence helpline',
      icon: '🛡️',
    ),
    
    // Child Safety
    HelplineModel(
      id: 'child_helpline',
      name: 'Child Helpline',
      number: '1098',
      category: 'Child Safety',
      description: 'Child protection and welfare',
      icon: '👶',
    ),
    
    // Mental Health
    HelplineModel(
      id: 'mental_health',
      name: 'Mental Health',
      number: '1800-599-0019',
      category: 'Mental Health',
      description: 'Mental health support',
      icon: '🧠',
    ),
    HelplineModel(
      id: 'suicide_prevention',
      name: 'Suicide Prevention',
      number: '1800-599-0019',
      category: 'Mental Health',
      description: 'Crisis intervention and suicide prevention',
      icon: '💚',
    ),
    
    // Disaster Management
    HelplineModel(
      id: 'disaster_management',
      name: 'Disaster Management',
      number: '108',
      category: 'Disaster',
      description: 'Disaster management and relief',
      icon: '🌪️',
    ),
    
    // Cyber Crime
    HelplineModel(
      id: 'cyber_crime',
      name: 'Cyber Crime',
      number: '1930',
      category: 'Cyber Crime',
      description: 'Cyber crime reporting and support',
      icon: '💻',
    ),
    
    // Senior Citizens
    HelplineModel(
      id: 'senior_citizens',
      name: 'Senior Citizens',
      number: '14567',
      category: 'Senior Citizens',
      description: 'Senior citizen support and assistance',
      icon: '👴',
    ),
    
    // Road Safety
    HelplineModel(
      id: 'road_safety',
      name: 'Road Safety',
      number: '1033',
      category: 'Road Safety',
      description: 'Road accident and safety helpline',
      icon: '🛣️',
    ),
  ];

  static List<HelplineModel> getHelplinesByCategory(String category) {
    return helplines.where((helpline) => helpline.category == category).toList();
  }

  static List<String> getCategories() {
    return helplines.map((helpline) => helpline.category).toSet().toList();
  }

  static HelplineModel? getHelplineById(String id) {
    try {
      return helplines.firstWhere((helpline) => helpline.id == id);
    } catch (e) {
      return null;
    }
  }
}
