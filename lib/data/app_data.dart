// Single source of truth for hardcoded contacts.
// Both the Contacts page and the Tasks page import from here so they always
// show the same list. When we add a real database, this file goes away.
final List<Map<String, String>> kContacts = [
  {'name': 'Marcus Webb',    'service': 'Lawn Mowing',    'phone': '555-111-2222', 'email': 'marcus@example.com',  'schedule': 'Every Monday',    'price': '\$85',  'status': 'Paid',    'address': '12 Oak Lane',     'notes': 'Gate code is 1234. Dog in backyard — keep closed.'},
  {'name': 'Sandra Torres',  'service': 'Hedge Trimming', 'phone': '555-333-4444', 'email': 'sandra@example.com',  'schedule': 'Every Wednesday', 'price': '\$65',  'status': 'Paid',    'address': '88 Maple Ave',    'notes': 'Prefers contact by text only.'},
  {'name': 'Derek Liu',      'service': 'Lawn + Edging',  'phone': '555-555-6666', 'email': 'derek@example.com',   'schedule': 'Every Friday',    'price': '\$120', 'status': 'Pending', 'address': '5 Birchwood Ct',  'notes': ''},
  {'name': 'Brenda Okafor',  'service': 'Leaf Cleanup',   'phone': '555-777-8888', 'email': 'brenda@example.com',  'schedule': 'Bi-weekly',       'price': '\$55',  'status': 'Pending', 'address': '200 Elm Street',  'notes': 'Invoice sent — waiting on check.'},
  {'name': 'Tom Harrington', 'service': 'Lawn Mowing',    'phone': '555-999-0000', 'email': 'tomh@example.com',    'schedule': 'Every Tuesday',   'price': '\$75',  'status': 'Overdue', 'address': '77 Ridgeline Rd', 'notes': 'Called twice — no response. Try again Friday.'},
  {'name': 'Karen Mills',    'service': 'Cleanup',        'phone': '555-222-3333', 'email': 'karen@example.com',   'schedule': 'Monthly',         'price': '\$90',  'status': 'Overdue', 'address': '31 Sunset Blvd',  'notes': 'Left voicemail. Follow up by end of week.'},
];
