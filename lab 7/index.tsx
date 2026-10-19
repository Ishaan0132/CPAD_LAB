import React, { useState } from 'react';
import {
  SafeAreaView,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  FlatList,
  StatusBar,
  StyleSheet,
  Alert,
} from 'react-native';

const COLORS = {
  background: '#F6F3EA',
  surface: '#FFFEFA',
  primary: '#304F3D',
  primaryLight: '#42634D',
  sage: '#DCE5D5',
  softSage: '#E9ECDD',
  text: '#253D32',
  muted: '#898D7D',
  income: '#15935A',
  expense: '#DC5B43',
  border: '#E5E2D7',
};

const CATEGORIES = {
  Expense: [
    { name: 'Food', icon: '🍔' },
    { name: 'Travel', icon: '🚗' },
    { name: 'Shopping', icon: '🛍️' },
    { name: 'Bills', icon: '🧾' },
    { name: 'Other', icon: '📦' },
  ],
  Income: [
    { name: 'Salary', icon: '💼' },
    { name: 'Business', icon: '🏪' },
    { name: 'Gift', icon: '🎁' },
    { name: 'Other', icon: '💰' },
  ],
};

const formatMoney = (value) =>
  value.toLocaleString('en-IN', { maximumFractionDigits: 2 });

function SummaryCard({ title, amount, color, icon }) {
  return (
    <View style={styles.summaryCard}>
      <View style={styles.summaryHeading}>
        <Text style={styles.summaryIcon}>{icon}</Text>
        <Text style={styles.mutedText}>{title}</Text>
      </View>
      <Text
        style={[styles.summaryAmount, { color }]}
        numberOfLines={1}
        adjustsFontSizeToFit
      >
        ₹{formatMoney(amount)}
      </Text>
    </View>
  );
}

function TransactionItem({ item, onDelete }) {
  const isIncome = item.type === 'Income';
  const categoryIcon =
    CATEGORIES[item.type]?.find((category) => category.name === item.category)?.icon || '📦';

  return (
    <View style={styles.transactionCard}>
      <View style={styles.transactionIcon}>
        <Text style={styles.emoji}>{categoryIcon}</Text>
      </View>
      <View style={styles.transactionInfo}>
        <Text style={styles.transactionName} numberOfLines={1}>
          {item.description}
        </Text>
        <Text style={styles.transactionMeta}>
          {item.category} · {item.type}
        </Text>
      </View>
      <View style={styles.amountColumn}>
        <Text
          style={[
            styles.transactionAmount,
            { color: isIncome ? COLORS.income : COLORS.expense },
          ]}
          numberOfLines={1}
          adjustsFontSizeToFit
        >
          {isIncome ? '+' : '−'}₹{formatMoney(item.amount)}
        </Text>
        <TouchableOpacity
          onPress={() => onDelete(item.id)}
          accessibilityRole="button"
          accessibilityLabel={`Delete ${item.description}`}
          style={styles.deleteButton}
        >
          <Text style={styles.deleteText}>Delete</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

export default function App() {
  const [transactions, setTransactions] = useState([]);
  const [description, setDescription] = useState('');
  const [amount, setAmount] = useState('');
  const [type, setType] = useState('Expense');
  const [category, setCategory] = useState('Food');

  const income = transactions
    .filter((transaction) => transaction.type === 'Income')
    .reduce((sum, transaction) => sum + transaction.amount, 0);
  const expenses = transactions
    .filter((transaction) => transaction.type === 'Expense')
    .reduce((sum, transaction) => sum + transaction.amount, 0);
  const balance = income - expenses;

  const selectType = (value) => {
    setType(value);
    setCategory(value === 'Income' ? 'Salary' : 'Food');
  };

  const addTransaction = () => {
    const value = Number(amount);
    if (
      !description.trim() ||
      !amount.trim() ||
      !Number.isFinite(value) ||
      value <= 0
    ) {
      Alert.alert(
        'Check your details',
        'Enter a description and a valid amount greater than zero.'
      );
      return;
    }

    setTransactions((previous) => [
      {
        id: `${Date.now()}-${Math.random()}`,
        description: description.trim(),
        amount: value,
        type,
        category,
      },
      ...previous,
    ]);
    setDescription('');
    setAmount('');
  };

  const deleteTransaction = (id) => {
    Alert.alert(
      'Delete transaction?',
      'This entry will be removed from your history.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: () =>
            setTransactions((previous) =>
              previous.filter((transaction) => transaction.id !== id)
            ),
        },
      ]
    );
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar barStyle="dark-content" backgroundColor={COLORS.background} />
      <FlatList
        data={transactions}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <TransactionItem item={item} onDelete={deleteTransaction} />
        )}
        contentContainerStyle={styles.listContent}
        keyboardShouldPersistTaps="handled"
        ListHeaderComponent={
          <View>
            <View style={styles.header}>
              <View>
                <Text style={styles.eyebrow}>YOUR FINANCIAL OVERVIEW</Text>
                <Text style={styles.heading}>My Expenses</Text>
              </View>
              <View style={styles.walletIcon}>
                <Text style={styles.walletEmoji}>👛</Text>
              </View>
            </View>

            <View style={styles.balanceCard}>
              <Text style={styles.balanceLabel}>Total balance</Text>
              <Text style={styles.balanceAmount} numberOfLines={1} adjustsFontSizeToFit>
                ₹{balance.toLocaleString('en-IN', {
                  minimumFractionDigits: 2,
                  maximumFractionDigits: 2,
                })}
              </Text>
              <View style={styles.balanceDivider} />
              <View style={styles.balanceRow}>
                <View style={styles.balanceItem}>
                  <Text style={styles.balanceSmall}>↙ Income</Text>
                  <Text style={styles.balanceValue}>₹{formatMoney(income)}</Text>
                </View>
                <View style={styles.balanceItem}>
                  <Text style={styles.balanceSmall}>↗ Expenses</Text>
                  <Text style={styles.balanceValue}>₹{formatMoney(expenses)}</Text>
                </View>
              </View>
            </View>

            <View style={styles.summaryRow}>
              <SummaryCard title="Income" amount={income} color={COLORS.income} icon="↙" />
              <SummaryCard title="Expenses" amount={expenses} color={COLORS.expense} icon="↗" />
            </View>

            <Text style={styles.sectionTitle}>Add transaction</Text>
            <View style={styles.formCard}>
              <View style={styles.typeSelector}>
                {['Expense', 'Income'].map((option) => (
                  <TouchableOpacity
                    key={option}
                    style={[styles.typeOption, type === option && styles.typeSelected]}
                    onPress={() => selectType(option)}
                    accessibilityRole="button"
                    accessibilityState={{ selected: type === option }}
                  >
                    <Text style={[styles.typeText, type === option && styles.typeTextSelected]}>
                      {option}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>

              <Text style={styles.fieldLabel}>Amount (₹)</Text>
              <TextInput
                style={styles.amountInput}
                placeholder="0.00"
                placeholderTextColor="#A4ADBE"
                value={amount}
                onChangeText={setAmount}
                keyboardType="decimal-pad"
                accessibilityLabel="Transaction amount"
              />

              <Text style={styles.fieldLabel}>Description</Text>
              <TextInput
                style={styles.input}
                placeholder="What was it for?"
                placeholderTextColor="#A4ADBE"
                value={description}
                onChangeText={setDescription}
                maxLength={100}
                returnKeyType="done"
                accessibilityLabel="Transaction description"
              />

              <Text style={styles.fieldLabel}>Category</Text>
              <View style={styles.categoryRow}>
                {CATEGORIES[type].map((item) => (
                  <TouchableOpacity
                    key={item.name}
                    style={[styles.categoryChip, category === item.name && styles.categorySelected]}
                    onPress={() => setCategory(item.name)}
                    accessibilityRole="button"
                    accessibilityState={{ selected: category === item.name }}
                  >
                    <Text style={styles.categoryEmoji}>{item.icon}</Text>
                    <Text style={[styles.categoryText, category === item.name && styles.categoryTextSelected]}>
                      {item.name}
                    </Text>
                  </TouchableOpacity>
                ))}
              </View>

              <TouchableOpacity
                style={styles.addButton}
                onPress={addTransaction}
                accessibilityRole="button"
              >
                <Text style={styles.addButtonText}>+ Save transaction</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.historyHeader}>
              <Text style={styles.sectionTitle}>Recent activity</Text>
              <Text style={styles.countText}>{transactions.length} entries</Text>
            </View>
          </View>
        }
        ListEmptyComponent={
          <View style={styles.emptyCard}>
            <Text style={styles.emptyEmoji}>🧾</Text>
            <Text style={styles.emptyTitle}>Nothing here yet</Text>
            <Text style={styles.emptyText}>Add your first transaction to see it here.</Text>
          </View>
        }
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: COLORS.background },
  listContent: { paddingHorizontal: 20, paddingTop: 18, paddingBottom: 36, flexGrow: 1 },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 22 },
  eyebrow: { color: COLORS.muted, fontSize: 11, fontWeight: '800', letterSpacing: 1.4, marginBottom: 6 },
  heading: { color: COLORS.text, fontSize: 29, fontWeight: '800', letterSpacing: -0.6 },
  walletIcon: { width: 52, height: 52, borderRadius: 18, backgroundColor: COLORS.sage, alignItems: 'center', justifyContent: 'center' },
  walletEmoji: { fontSize: 27 },
  balanceCard: { backgroundColor: COLORS.primary, padding: 24, borderRadius: 24, marginBottom: 18 },
  balanceLabel: { color: COLORS.sage, fontSize: 14 },
  balanceAmount: { color: COLORS.surface, fontSize: 34, fontWeight: '800', marginTop: 10 },
  balanceDivider: { height: 1, backgroundColor: '#66806B', marginVertical: 20 },
  balanceRow: { flexDirection: 'row', justifyContent: 'space-between' },
  balanceItem: { flex: 1 },
  balanceSmall: { color: COLORS.sage, fontSize: 13, marginBottom: 7 },
  balanceValue: { color: COLORS.surface, fontSize: 17, fontWeight: '700' },
  summaryRow: { flexDirection: 'row', gap: 12, marginBottom: 2 },
  summaryCard: { flex: 1, backgroundColor: COLORS.surface, padding: 16, borderRadius: 18, borderWidth: 1, borderColor: COLORS.border },
  summaryHeading: { flexDirection: 'row', alignItems: 'center', gap: 8, marginBottom: 12 },
  summaryIcon: { fontSize: 16, color: COLORS.primary, fontWeight: '800' },
  mutedText: { color: COLORS.muted, fontSize: 13 },
  summaryAmount: { fontSize: 20, fontWeight: '800' },
  sectionTitle: { color: COLORS.text, fontSize: 21, fontWeight: '800', marginTop: 22, marginBottom: 14 },
  formCard: { backgroundColor: '#E5E8D9', padding: 17, borderRadius: 22 },
  typeSelector: { flexDirection: 'row', backgroundColor: '#D5D9C9', borderRadius: 12, padding: 4, marginBottom: 20 },
  typeOption: { flex: 1, paddingVertical: 11, borderRadius: 9, alignItems: 'center' },
  typeSelected: { backgroundColor: COLORS.primary },
  typeText: { color: COLORS.text, fontSize: 14, fontWeight: '700' },
  typeTextSelected: { color: '#FFFFFF' },
  fieldLabel: { color: COLORS.text, fontSize: 13, fontWeight: '700', marginBottom: 8 },
  amountInput: { backgroundColor: COLORS.surface, borderRadius: 12, padding: 15, color: COLORS.text, fontSize: 20, fontWeight: '700', marginBottom: 16 },
  input: { backgroundColor: COLORS.surface, borderRadius: 12, padding: 15, color: COLORS.text, marginBottom: 16 },
  categoryRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginBottom: 20 },
  categoryChip: { flexDirection: 'row', alignItems: 'center', gap: 6, backgroundColor: COLORS.surface, borderWidth: 1, borderColor: COLORS.border, paddingVertical: 9, paddingHorizontal: 11, borderRadius: 12 },
  categorySelected: { backgroundColor: COLORS.sage, borderColor: COLORS.primary },
  categoryEmoji: { fontSize: 15 },
  categoryText: { color: COLORS.text, fontSize: 12, fontWeight: '600' },
  categoryTextSelected: { color: COLORS.primary, fontWeight: '800' },
  addButton: { backgroundColor: COLORS.primary, borderRadius: 14, paddingVertical: 16, alignItems: 'center' },
  addButtonText: { color: '#FFFFFF', fontSize: 15, fontWeight: '800' },
  historyHeader: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  countText: { color: COLORS.muted, fontSize: 12, marginTop: 22, marginBottom: 14 },
  transactionCard: { backgroundColor: COLORS.surface, flexDirection: 'row', alignItems: 'center', padding: 15, borderRadius: 17, marginBottom: 10, gap: 12, borderWidth: 1, borderColor: COLORS.border },
  transactionIcon: { width: 42, height: 42, borderRadius: 14, backgroundColor: COLORS.softSage, alignItems: 'center', justifyContent: 'center' },
  emoji: { fontSize: 21 },
  transactionInfo: { flex: 1, minWidth: 0 },
  transactionName: { color: COLORS.text, fontSize: 15, fontWeight: '700' },
  transactionMeta: { color: COLORS.muted, fontSize: 12, marginTop: 5 },
  amountColumn: { alignItems: 'flex-end', maxWidth: '42%' },
  transactionAmount: { fontSize: 14, fontWeight: '800', marginBottom: 7 },
  deleteButton: { backgroundColor: '#F5E4DC', paddingVertical: 5, paddingHorizontal: 8, borderRadius: 6 },
  deleteText: { color: COLORS.expense, fontSize: 11, fontWeight: '700' },
  emptyCard: { alignItems: 'center', backgroundColor: COLORS.surface, borderRadius: 18, borderWidth: 1, borderColor: COLORS.border, padding: 26, marginTop: 2 },
  emptyEmoji: { fontSize: 30, marginBottom: 10 },
  emptyTitle: { color: COLORS.text, fontSize: 16, fontWeight: '800', marginBottom: 6 },
  emptyText: { color: COLORS.muted, fontSize: 13, textAlign: 'center', lineHeight: 19 },
});
