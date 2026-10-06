import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  Pressable,
  FlatList,
  StyleSheet,
  Alert,
  Platform,
} from 'react-native';

export default function App() {
  const [description, setDescription] = useState('');
  const [amount, setAmount] = useState('');
  const [category, setCategory] = useState('Food');

  const [expenses, setExpenses] = useState([
    {
      id: '1',
      description: 'Lunch',
      amount: 250,
      category: 'Food',
    },
    {
      id: '2',
      description: 'Bus Travel',
      amount: 80,
      category: 'Travel',
    },
    {
      id: '3',
      description: 'College Books',
      amount: 700,
      category: 'Education',
    },
  ]);

  const categories = ['Food', 'Travel', 'Shopping', 'Education'];

  const totalExpense = expenses.reduce(
    (total, item) => total + item.amount,
    0
  );

  const addExpense = () => {
    if (!description.trim() || !amount.trim()) {
      if (Platform.OS === 'web') {
        alert('Please enter both description and amount.');
      } else {
        Alert.alert(
          'Missing Information',
          'Please enter both description and amount.'
        );
      }
      return;
    }

    const numericAmount = parseFloat(amount);

    if (isNaN(numericAmount) || numericAmount <= 0) {
      if (Platform.OS === 'web') {
        alert('Please enter a valid amount.');
      } else {
        Alert.alert('Invalid Amount', 'Please enter a valid amount.');
      }
      return;
    }

    const newExpense = {
      id: Date.now().toString(),
      description: description.trim(),
      amount: numericAmount,
      category: category,
    };

    setExpenses([newExpense, ...expenses]);

    setDescription('');
    setAmount('');
  };

  const deleteExpense = (id) => {
    setExpenses(expenses.filter((item) => item.id !== id));
  };

  const getCategoryIcon = (category) => {
    switch (category) {
      case 'Food':
        return '🍔';
      case 'Travel':
        return '🚌';
      case 'Shopping':
        return '🛍️';
      case 'Education':
        return '📚';
      default:
        return '💰';
    }
  };

  const renderExpense = ({ item }) => (
    <View style={styles.expenseCard}>
      <View style={styles.expenseLeft}>
        <View style={styles.iconContainer}>
          <Text style={styles.icon}>
            {getCategoryIcon(item.category)}
          </Text>
        </View>

        <View>
          <Text style={styles.expenseName}>
            {item.description}
          </Text>

          <Text style={styles.expenseCategory}>
            {item.category}
          </Text>
        </View>
      </View>

      <View style={styles.expenseRight}>
        <Text style={styles.expenseAmount}>
          ₹{item.amount.toFixed(2)}
        </Text>

        <Pressable
          onPress={() => deleteExpense(item.id)}
          style={styles.deleteButton}
        >
          <Text style={styles.deleteText}>Delete</Text>
        </Pressable>
      </View>
    </View>
  );

  return (
    <View style={styles.container}>
      <FlatList
        data={expenses}
        renderItem={renderExpense}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.content}
        ListHeaderComponent={
          <>
            {/* Header */}
            <View style={styles.header}>
              <View>
                <Text style={styles.appTitle}>
                  Expense Tracker
                </Text>

                <Text style={styles.subtitle}>
                  Manage your student expenses
                </Text>
              </View>

              <Text style={styles.headerIcon}>💰</Text>
            </View>

            {/* Total Card */}
            <View style={styles.totalCard}>
              <Text style={styles.totalLabel}>
                Total Expenses
              </Text>

              <Text style={styles.totalAmount}>
                ₹{totalExpense.toFixed(2)}
              </Text>

              <Text style={styles.totalDescription}>
                {expenses.length} transaction
                {expenses.length !== 1 ? 's' : ''}
              </Text>
            </View>

            {/* Add Expense */}
            <View style={styles.formCard}>
              <Text style={styles.sectionTitle}>
                Add New Expense
              </Text>

              <Text style={styles.inputLabel}>
                Description
              </Text>

              <TextInput
                style={styles.input}
                placeholder="e.g. Lunch, Books, Bus"
                value={description}
                onChangeText={setDescription}
              />

              <Text style={styles.inputLabel}>
                Amount
              </Text>

              <TextInput
                style={styles.input}
                placeholder="Enter amount"
                value={amount}
                onChangeText={setAmount}
                keyboardType="numeric"
              />

              <Text style={styles.inputLabel}>
                Category
              </Text>

              <View style={styles.categoryContainer}>
                {categories.map((item) => (
                  <Pressable
                    key={item}
                    onPress={() => setCategory(item)}
                    style={[
                      styles.categoryButton,
                      category === item &&
                        styles.selectedCategory,
                    ]}
                  >
                    <Text
                      style={[
                        styles.categoryText,
                        category === item &&
                          styles.selectedCategoryText,
                      ]}
                    >
                      {getCategoryIcon(item)} {item}
                    </Text>
                  </Pressable>
                ))}
              </View>

              <Pressable
                style={styles.addButton}
                onPress={addExpense}
              >
                <Text style={styles.addButtonText}>
                  + Add Expense
                </Text>
              </Pressable>
            </View>

            {/* Expense Heading */}
            <View style={styles.listHeader}>
              <Text style={styles.sectionTitle}>
                Recent Expenses
              </Text>

              <Text style={styles.countText}>
                {expenses.length} items
              </Text>
            </View>
          </>
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyIcon}>📭</Text>

            <Text style={styles.emptyText}>
              No expenses yet
            </Text>

            <Text style={styles.emptySubtext}>
              Add your first expense above.
            </Text>
          </View>
        }
        ListFooterComponent={
          <Text style={styles.footer}>
            React Native • Expo • Cross Platform
          </Text>
        }
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f7fb',
  },

  content: {
    width: '100%',
    maxWidth: 700,
    alignSelf: 'center',
    padding: 20,
    paddingBottom: 40,
  },

  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },

  appTitle: {
    fontSize: 28,
    fontWeight: '800',
    color: '#172033',
  },

  subtitle: {
    fontSize: 14,
    color: '#70798c',
    marginTop: 4,
  },

  headerIcon: {
    fontSize: 35,
  },

  totalCard: {
    backgroundColor: '#4f46e5',
    borderRadius: 18,
    padding: 24,
    marginBottom: 20,
  },

  totalLabel: {
    color: '#ddd9ff',
    fontSize: 14,
    fontWeight: '600',
  },

  totalAmount: {
    color: '#ffffff',
    fontSize: 36,
    fontWeight: '800',
    marginTop: 6,
  },

  totalDescription: {
    color: '#ddd9ff',
    fontSize: 13,
    marginTop: 4,
  },

  formCard: {
    backgroundColor: '#ffffff',
    borderRadius: 18,
    padding: 20,
    marginBottom: 25,

    elevation: 3,

    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.08,
    shadowRadius: 5,
  },

  sectionTitle: {
    fontSize: 19,
    fontWeight: '750',
    color: '#172033',
    marginBottom: 15,
  },

  inputLabel: {
    fontSize: 13,
    fontWeight: '600',
    color: '#4c5568',
    marginBottom: 7,
  },

  input: {
    borderWidth: 1,
    borderColor: '#d9deea',
    borderRadius: 10,
    paddingHorizontal: 14,
    paddingVertical: 12,
    fontSize: 15,
    marginBottom: 15,
    backgroundColor: '#fafbfe',
  },

  categoryContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 18,
  },

  categoryButton: {
    borderWidth: 1,
    borderColor: '#d9deea',
    borderRadius: 20,
    paddingHorizontal: 12,
    paddingVertical: 9,
  },

  selectedCategory: {
    backgroundColor: '#4f46e5',
    borderColor: '#4f46e5',
  },

  categoryText: {
    color: '#4c5568',
    fontSize: 13,
    fontWeight: '600',
  },

  selectedCategoryText: {
    color: '#ffffff',
  },

  addButton: {
    backgroundColor: '#4f46e5',
    borderRadius: 10,
    paddingVertical: 14,
    alignItems: 'center',
  },

  addButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '700',
  },

  listHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  countText: {
    color: '#70798c',
    fontSize: 13,
    marginBottom: 15,
  },

  expenseCard: {
    backgroundColor: '#ffffff',
    borderRadius: 14,
    padding: 16,
    marginBottom: 10,

    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',

    elevation: 2,

    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.06,
    shadowRadius: 3,
  },

  expenseLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },

  iconContainer: {
    width: 45,
    height: 45,
    borderRadius: 23,
    backgroundColor: '#f0efff',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },

  icon: {
    fontSize: 21,
  },

  expenseName: {
    fontSize: 15,
    fontWeight: '700',
    color: '#172033',
  },

  expenseCategory: {
    fontSize: 12,
    color: '#7b8496',
    marginTop: 3,
  },

  expenseRight: {
    alignItems: 'flex-end',
  },

  expenseAmount: {
    fontSize: 16,
    fontWeight: '800',
    color: '#172033',
  },

  deleteButton: {
    marginTop: 5,
  },

  deleteText: {
    fontSize: 12,
    color: '#e04444',
    fontWeight: '600',
  },

  emptyContainer: {
    alignItems: 'center',
    paddingVertical: 40,
  },

  emptyIcon: {
    fontSize: 40,
    marginBottom: 10,
  },

  emptyText: {
    fontSize: 17,
    fontWeight: '700',
    color: '#172033',
  },

  emptySubtext: {
    fontSize: 13,
    color: '#7b8496',
    marginTop: 5,
  },

  footer: {
    textAlign: 'center',
    color: '#9aa1af',
    fontSize: 12,
    marginTop: 25,
  },
});
