using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Configuration;
using Microsoft.Win32;
using System.Text.RegularExpressions;

namespace lab8
{
    /// <summary>
    /// Логика взаимодействия для MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void Check_ALL_People(object sender, RoutedEventArgs e)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
            string query = "SELECT * FROM CrewMember";

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                SqlTransaction transaction = connection.BeginTransaction();

                try
                {
                    SqlCommand command = new SqlCommand(query, connection, transaction);
                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    DataTable dataTable = new DataTable();

                    adapter.Fill(dataTable);

                    CrewMembersGrid.ItemsSource = dataTable.DefaultView;

                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                }
                finally
                {
                    connection.Close();
                }
            }
        }

        private void Check_ALL_PLANES(object sender, RoutedEventArgs e)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
            string query = "SELECT * FROM Airplane";

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                SqlTransaction transaction = connection.BeginTransaction();

                try
                {
                    SqlCommand command = new SqlCommand(query, connection, transaction);
                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    DataTable dataTable = new DataTable();

                    adapter.Fill(dataTable);

                    AirplaneGrid.ItemsSource = dataTable.DefaultView;

                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                }
                finally
                {
                    connection.Close();
                }
            }
        }

        //добавление самолёта
        private void Save_Plane(object sender, RoutedEventArgs e)
        {
            if (!int.TryParse(AirplaneIDTextBox.Text, out int airplaneID) || airplaneID < 0)
            {
                MessageBox.Show("Неверный формат значения в поле 'ID'. Пожалуйста, введите целое число.");
                return;
            }

            string airplaneType = AirplaneTypeComboBox.Text;
            if (string.IsNullOrEmpty(airplaneType))
            {
                MessageBox.Show("Поле 'Тип' должно быть заполнено.");
                return;
            }

            if (!decimal.TryParse(CargoCapacityTextBox.Text, out decimal cargoCapacity) || cargoCapacity < 0)
            {
                MessageBox.Show("Неверный формат значения в поле 'Грузоподъемность'. Пожалуйста, введите положительное числовое значение.");
                return;
            }

            if (!int.TryParse(PassengerSeatsTextBox.Text, out int passengerSeats) || passengerSeats < 0)
            {
                MessageBox.Show("Неверный формат значения в поле 'Количество пассажирских мест'. Пожалуйста, введите положительное целое число.");
                return;
            }

            string yearOfManufacture = YearOfManufactureTextBox.Text;
            if (string.IsNullOrEmpty(yearOfManufacture))
            {
                MessageBox.Show("Поле 'Год производства' должно быть заполнено.");
                return;
            }


            string model = ModelTextBox.Text;
            if (string.IsNullOrEmpty(model))
            {
                MessageBox.Show("Поле 'Модель' должно быть заполнено.");
                return;
            }

            DateTime? lastMaintenanceDate = LastMaintenanceDatePicker.SelectedDate ?? DateTime.MinValue;


            if (lastMaintenanceDate > DateTime.Now)
            {
                MessageBox.Show("Дата последнего то не может быть больше текущего момента.");
                return;
            }

            if (!int.TryParse(yearOfManufacture, out int year))
            {
                MessageBox.Show("Неверный формат значения в поле 'Год производства'. Пожалуйста, введите целое число.");
                return;
            }

            if (year > DateTime.Now.Year)
            {
                MessageBox.Show("Год выпуска не может быть больше текущего года.");
                return;
            }

            if (lastMaintenanceDate.Value.Year < year)
            {
                MessageBox.Show("Год то не может раньше больше текущего года.");
                return;
            }

            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
            string selectQuery = "SELECT COUNT(*) FROM Airplane WHERE ID = @AirplaneID";
            string insertQuery = $"INSERT INTO Airplane (ID, Type, Model, Passenger_Seats, Year_of_Manufacture, Cargo_Capacity, Last_Maintenance_Date) VALUES (@AirplaneID, @AirplaneType, @Model,@PassengerSeats,@YearOfManufacture, @CargoCapacity, @LastMaintenanceDate)";

            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    using (SqlCommand selectCommand = new SqlCommand(selectQuery, connection))
                    {
                        selectCommand.Parameters.AddWithValue("@AirplaneID", airplaneID);

                        int existingCount = (int)selectCommand.ExecuteScalar();

                        if (existingCount > 0)
                        {
                            MessageBox.Show("Запись с указанным ID уже существует. Пожалуйста, выберите другой ID.");
                            return;
                        }
                    }

                    using (SqlCommand command = new SqlCommand(insertQuery, connection))
                    {
                        command.Parameters.AddWithValue("@AirplaneID", airplaneID);
                        command.Parameters.AddWithValue("@AirplaneType", airplaneType);
                        command.Parameters.AddWithValue("@CargoCapacity", cargoCapacity);
                        command.Parameters.AddWithValue("@YearOfManufacture", yearOfManufacture);
                        command.Parameters.AddWithValue("@PassengerSeats", passengerSeats);
                        command.Parameters.AddWithValue("@Model", model);
                        command.Parameters.AddWithValue("@LastMaintenanceDate", lastMaintenanceDate);

                        command.ExecuteNonQuery();

                        MessageBox.Show("Данные успешно записаны в таблицу 'Самолеты'.");
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при записи данных: {ex.Message}");
            }
        }


        //получение детальной информации для самолётов
        private void Check_plane(object sender, RoutedEventArgs e)
        {
            string airplaneID = AirplaneIDTextBox.Text;
            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
            string selectQuery = "SELECT * FROM Airplane WHERE ID = @AirplaneID";

            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    using (SqlTransaction transaction = connection.BeginTransaction())
                    {
                        try
                        {
                            using (SqlCommand command = new SqlCommand(selectQuery, connection, transaction))
                            {
                                command.Parameters.AddWithValue("@AirplaneID", airplaneID);

                                using (SqlDataReader reader = command.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        string airplaneType = reader["Type"].ToString();
                                        string cargoCapacity = reader["Cargo_Capacity"].ToString();
                                        string yearOfManufacture = reader["Year_of_Manufacture"].ToString();
                                        string passengerSeats = reader["Passenger_Seats"].ToString();
                                        string model = reader["Model"].ToString();
                                        DateTime lastMaintenanceDate = Convert.ToDateTime(reader["Last_Maintenance_Date"]);

                                        AirplaneTypeComboBox.Text = airplaneType;
                                        CargoCapacityTextBox.Text = cargoCapacity;
                                        YearOfManufactureTextBox.Text = yearOfManufacture;
                                        PassengerSeatsTextBox.Text = passengerSeats;
                                        ModelTextBox.Text = model;
                                        LastMaintenanceDatePicker.SelectedDate = lastMaintenanceDate;
                                    }
                                    else
                                    {
                                        MessageBox.Show("Самолет с указанным ID не найден.");
                                    }
                                }
                            }

                            transaction.Commit();
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            MessageBox.Show($"Ошибка при получении информации: {ex.Message}");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при подключении к базе данных: {ex.Message}");
            }
        }


        //удаление самолёта
        private void Delete_plane(object sender, RoutedEventArgs e)
        {
            string airplaneID = AirplaneIDTextBox.Text;
            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    using (SqlTransaction transaction = connection.BeginTransaction())
                    {
                        try
                        {
                            using (SqlCommand command = new SqlCommand("DeleteAirplane", connection, transaction))
                            {
                                command.CommandType = CommandType.StoredProcedure;
                                command.Parameters.AddWithValue("@AirplaneID", airplaneID);

                                command.ExecuteNonQuery();
                            }

                            AirplaneIDTextBox.Text = string.Empty;
                            AirplaneTypeComboBox.Text = string.Empty;
                            CargoCapacityTextBox.Text = string.Empty;
                            YearOfManufactureTextBox.Text = string.Empty;
                            PassengerSeatsTextBox.Text = string.Empty;
                            ModelTextBox.Text = string.Empty;
                            LastMaintenanceDatePicker.SelectedDate = null;

                            transaction.Commit();
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            MessageBox.Show($"Ошибка при удалении самолета: {ex.Message}");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при подключении к базе данных: {ex.Message}");
            }
        }


        //обновление данных о самолёте
        private void Return_plane(object sender, RoutedEventArgs e)
        {


            string airplaneType = AirplaneTypeComboBox.Text;
            if (string.IsNullOrEmpty(airplaneType))
            {
                MessageBox.Show("Поле 'Тип' должно быть заполнено.");
                return;
            }

            if (!int.TryParse(AirplaneIDTextBox.Text, out int airplaneID) || airplaneID < 0)
            {
                MessageBox.Show("Неверный формат значения в поле 'ID'. Пожалуйста, введите целое число.");
                return;
            }

            if (!decimal.TryParse(CargoCapacityTextBox.Text, out decimal cargoCapacity) || cargoCapacity < 0)
            {
                MessageBox.Show("Неверный формат значения в поле 'Грузоподъемность'. Пожалуйста, введите положительное числовое значение.");
                return;
            }

            if (!int.TryParse(PassengerSeatsTextBox.Text, out int passengerSeats) || passengerSeats < 0)
            {
                MessageBox.Show("Неверный формат значения в поле 'Количество пассажирских мест'. Пожалуйста, введите положительное целое число.");
                return;
            }

            string yearOfManufacture = YearOfManufactureTextBox.Text;
            if (string.IsNullOrEmpty(yearOfManufacture))
            {
                MessageBox.Show("Поле 'Год производства' должно быть заполнено.");
                return;
            }

            string model = ModelTextBox.Text;
            if (string.IsNullOrEmpty(model))
            {
                MessageBox.Show("Поле 'Модель' должно быть заполнено.");
                return;
            }

            DateTime? lastMaintenanceDate = LastMaintenanceDatePicker.SelectedDate ?? DateTime.MinValue;


            if (lastMaintenanceDate > DateTime.Now)
            {
                MessageBox.Show("Дата последнего то не может быть больше текущего момента.");
                return;
            }

            if (!int.TryParse(yearOfManufacture, out int year))
            {
                MessageBox.Show("Неверный формат значения в поле 'Год производства'. Пожалуйста, введите целое число.");
                return;
            }

            if (year > DateTime.Now.Year)
            {
                MessageBox.Show("Год выпуска не может быть больше текущего года.");
                return;
            }

            if (lastMaintenanceDate.Value.Year < year)
            {
                MessageBox.Show("Год то не может раньше больше текущего года.");
                return;
            }

            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    using (SqlTransaction transaction = connection.BeginTransaction())
                    {
                        try
                        {
                            using (SqlCommand command = new SqlCommand("UPDATE Airplane SET Type = @AirplaneType, Model = @Model, Passenger_Seats = @PassengerSeats, Year_of_Manufacture = @YearOfManufacture, Cargo_Capacity = @CargoCapacity, Last_Maintenance_Date = @LastMaintenanceDate WHERE ID = @AirplaneID", connection, transaction))
                            {
                                command.Parameters.AddWithValue("@AirplaneID", airplaneID);
                                command.Parameters.AddWithValue("@AirplaneType", airplaneType);
                                command.Parameters.AddWithValue("@CargoCapacity", cargoCapacity);
                                command.Parameters.AddWithValue("@YearOfManufacture", yearOfManufacture);
                                command.Parameters.AddWithValue("@PassengerSeats", passengerSeats);
                                command.Parameters.AddWithValue("@Model", model);
                                command.Parameters.AddWithValue("@LastMaintenanceDate", lastMaintenanceDate);

                                command.ExecuteNonQuery();
                            }

                            transaction.Commit();
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            MessageBox.Show($"Ошибка при обновлении информации: {ex.Message}");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при подключении к базе данных: {ex.Message}");
            }
        }

        string SelectedPhotoFilePath;
        private void SelectPhoto()
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "Image Files (*.png;*.jpg;*.jpeg;*.gif;*.bmp)|*.png;*.jpg;*.jpeg;*.gif;*.bmp|All Files (*.*)|*.*";

            if (openFileDialog.ShowDialog() == true)
            {
                string selectedPhotoPath = openFileDialog.FileName;

                BitmapImage bitmapImage = new BitmapImage(new Uri(selectedPhotoPath));
                SelectedPhotoImage.Source = bitmapImage;

                SelectedPhotoFilePath = selectedPhotoPath;
            }
        }

        private void Chouse_Photo(object sender, RoutedEventArgs e)
        {
            SelectPhoto();
        }


        public bool CheckNamePattern(string name)
        {
            string pattern = @"^[А-Я][а-я]+ [А-Я][а-я]+ [А-Я][а-я]+$";
            return Regex.IsMatch(name, pattern);
        }


        //добавление нового члена экипажа
        private void Add_Crew(object sender, RoutedEventArgs e)
        {
            if (!int.TryParse(CrewId.Text, out int crewID) || crewID < 0)
            {
                MessageBox.Show("Неверный формат значения в поле 'ID'. Пожалуйста, введите положительное целое число.");
                return;
            }

            string fullName = CrewName.Text;
            string position = PositionComboBox.Text;

            if (!CheckNamePattern(fullName))
            {
                MessageBox.Show("Неверный формат значения в поле 'ФИО'. Пожалуйста, введите имя в формате 'Кореневский Кирилл Русланович'.");
                return;
            }

            if (!int.TryParse(CrewAge.Text, out int age))
            {
                MessageBox.Show("Неверный формат значения в поле 'Age'. Пожалуйста, введите целое число.");
                return;
            }


            if (age < 18 || age > 100)
            {
                MessageBox.Show("Неверное значение в поле 'Age'. Пожалуйста, введите возраст от 18 до 100 лет.");
                return;
            }

            if (!int.TryParse(CrewExp.Text, out int experience) || experience < 0)
            {
                MessageBox.Show("Неверный формат значения в поле 'Experience'. Пожалуйста, введите целое число.");
                return;
            }

            if (age < 23 && experience > 5)
            {
                MessageBox.Show("Неверное значение в поле 'Experience'. Стаж не может быть больше 5 лет, если возраст меньше 23 лет.");
                return;
            }

            string photo = SelectedPhotoFilePath;

            if (!int.TryParse(IdAirplain.Text, out int airplaneID))
            {
                MessageBox.Show("Неверный формат значения в поле 'ID'. Пожалуйста, введите целое число.");
                return;
            }

            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
            string selectQuery = "SELECT COUNT(*) FROM CrewMember WHERE ID = @CrewID";

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();


                using (SqlCommand selectCommand = new SqlCommand(selectQuery, connection))
                {
                    selectCommand.Parameters.AddWithValue("@CrewID", crewID);

                    int existingCount = (int)selectCommand.ExecuteScalar();

                    if (existingCount > 0)
                    {
                        MessageBox.Show("Запись с указанным ID уже существует. Пожалуйста, выберите другой ID.");
                        return;
                    }
                }


                try
                {
                    using (SqlCommand command = new SqlCommand("INSERT INTO CrewMember (ID, Full_Name, Position, Age, Experience, Photo, Airplane_ID) VALUES (@CrewID, @FullName, @Position, @Age, @Experience, @Photo, @AirplaneID)", connection))
                    {
                        command.Parameters.AddWithValue("@CrewID", crewID);
                        command.Parameters.AddWithValue("@FullName", fullName);
                        command.Parameters.AddWithValue("@Position", position);
                        command.Parameters.AddWithValue("@Age", age);
                        command.Parameters.AddWithValue("@Experience", experience);
                        command.Parameters.AddWithValue("@Photo", photo);
                        command.Parameters.AddWithValue("@AirplaneID", airplaneID);

                        command.ExecuteNonQuery();
                    }

                    MessageBox.Show("Член экипажа успешно добавлен.");
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Ошибка при добавлении члена экипажа: {ex.Message}");
                }
            }
        }


        //получение детальной информации о члене экипажа
        private void Check_crew(object sender, RoutedEventArgs e)
        {
            if (!int.TryParse(CrewId.Text, out int crewID))
            {
                MessageBox.Show("Неверный формат значения в поле 'id'. Пожалуйста, введите целое число.");
                return;
            }

            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                using (SqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {
                        using (SqlCommand command = new SqlCommand("SELECT Full_Name, Position, Age, Experience, Photo, Airplane_ID  FROM CrewMember WHERE ID = @CrewID", connection, transaction))
                        {
                            command.Parameters.AddWithValue("@CrewID", crewID);

                            using (SqlDataReader reader = command.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    string fullName = reader.GetString(0);
                                    string position = reader.GetString(1);
                                    int age = reader.GetInt32(2);
                                    int experience = reader.GetInt32(3);
                                    string photo = reader.GetString(4);
                                    int airplaneID = reader.GetInt32(5);

                                    CrewName.Text = fullName;
                                    PositionComboBox.Text = position;
                                    CrewAge.Text = age.ToString();
                                    CrewExp.Text = experience.ToString();
                                    IdAirplain.Text = airplaneID.ToString();

                                    SelectedPhotoImage.Source = new BitmapImage(new Uri(photo));
                                }
                                else
                                {
                                    MessageBox.Show("Член экипажа с указанным ID не найден.");
                                }
                            }
                        }

                        transaction.Commit();
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        MessageBox.Show($"Ошибка при получении информации о члене экипажа: {ex.Message}");
                    }
                }
            }
        }


        //удаление члена экипажа
        private void Delete_crew(object sender, RoutedEventArgs e)
        {
            if (!int.TryParse(CrewId.Text, out int crewID))
            {
                MessageBox.Show("Неверный формат значения в поле 'id'. Пожалуйста, введите целое число.");
                return;
            }

            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                using (SqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {
                        using (SqlCommand selectCommand = new SqlCommand("SELECT Full_Name FROM CrewMember WHERE ID = @CrewID", connection, transaction))
                        {
                            selectCommand.Parameters.AddWithValue("@CrewID", crewID);

                            object result = selectCommand.ExecuteScalar();
                            if (result == null)
                            {
                                MessageBox.Show("Член экипажа с указанным ID не найден.");
                                return;
                            }
                        }

                        using (SqlCommand deleteCommand = new SqlCommand("DELETE FROM CrewMember WHERE ID = @CrewID", connection, transaction))
                        {
                            deleteCommand.Parameters.AddWithValue("@CrewID", crewID);
                            deleteCommand.ExecuteNonQuery();
                        }

                        transaction.Commit();
                        MessageBox.Show("Член экипажа успешно удален.");
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        MessageBox.Show($"Ошибка при удалении члена экипажа: {ex.Message}");
                    }
                }
            }
        }



        //изменение информации о члене экипажа
        private void Return_crew(object sender, RoutedEventArgs e)
        {
            if (!int.TryParse(CrewId.Text, out int crewID))
            {
                MessageBox.Show("Неверный формат значения в поле 'id'. Пожалуйста, введите целое число.");
                return;
            }

            string fullName = CrewName.Text;
            string position = PositionComboBox.Text;

            if (!CheckNamePattern(fullName))
            {
                MessageBox.Show("Неверный формат значения в поле 'ФИО'. Пожалуйста, введите имя в формате 'Кореневский Кирилл Русланович'.");
                return;
            }

            if (!int.TryParse(CrewAge.Text, out int age))
            {
                MessageBox.Show("Неверный формат значения в поле 'age'. Пожалуйста, введите целое число.");
                return;
            }

            if (age < 18 || age > 100)
            {
                MessageBox.Show("Неверное значение в поле 'Age'. Пожалуйста, введите возраст от 18 до 100 лет.");
                return;
            }


            if (!int.TryParse(CrewExp.Text, out int experience))
            {
                MessageBox.Show("Неверный формат значения в поле 'experience'. Пожалуйста, введите целое число.");
                return;
            }

            if (age < 23 && experience > 5)
            {
                MessageBox.Show("Неверное значение в поле 'Experience'. Стаж не может быть больше 5 лет, если возраст меньше 23 лет.");
                return;
            }

            string photo = SelectedPhotoFilePath;

            if (!int.TryParse(IdAirplain.Text, out int airplaneID))
            {
                MessageBox.Show("Неверный формат значения в поле 'ID'. Пожалуйста, введите целое число.");
                return;
            }


            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                using (SqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {
                        using (SqlCommand selectCommand = new SqlCommand("SELECT Full_Name FROM CrewMember WHERE ID = @CrewID", connection, transaction))
                        {
                            selectCommand.Parameters.AddWithValue("@CrewID", crewID);

                            object result = selectCommand.ExecuteScalar();
                            if (result == null)
                            {
                                MessageBox.Show("Член экипажа с указанным ID не найден.");
                                return;
                            }
                        }

                        using (SqlCommand updateCommand = new SqlCommand("UPDATE CrewMember SET Full_Name = @FullName, Position = @Position, Age = @Age, Experience = @Experience, Photo = @Photo, Airplane_ID = @AirplaneID  WHERE ID = @CrewID", connection, transaction))
                        {
                            updateCommand.Parameters.AddWithValue("@FullName", fullName);
                            updateCommand.Parameters.AddWithValue("@Position", position);
                            updateCommand.Parameters.AddWithValue("@Age", age);
                            updateCommand.Parameters.AddWithValue("@Experience", experience);
                            updateCommand.Parameters.AddWithValue("@Photo", photo);

                            updateCommand.Parameters.AddWithValue("@CrewID", crewID);

                            updateCommand.Parameters.AddWithValue("@AirplaneID", airplaneID);

                            updateCommand.ExecuteNonQuery();
                        }

                        transaction.Commit();
                        MessageBox.Show("Информация о члене экипажа успешно обновлена.");
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        MessageBox.Show($"Ошибка при обновлении информации о члене экипажа: {ex.Message}");
                    }
                }
            }
        }


        //сортировка
        private void Sort(object sender, RoutedEventArgs e)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
            string query = "SELECT * FROM CrewMember order by Experience DESC";

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                SqlTransaction transaction = connection.BeginTransaction();

                try
                {
                    SqlCommand command = new SqlCommand(query, connection, transaction);
                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    DataTable dataTable = new DataTable();

                    adapter.Fill(dataTable);

                    CrewMembersGrid.ItemsSource = dataTable.DefaultView;

                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                }
                finally
                {
                    connection.Close();
                }
            }

            string query2 = "SELECT * FROM Airplane order by Year_of_Manufacture DESC";

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                SqlTransaction transaction = connection.BeginTransaction();

                try
                {
                    SqlCommand command = new SqlCommand(query2, connection, transaction);
                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    DataTable dataTable = new DataTable();

                    adapter.Fill(dataTable);

                    AirplaneGrid.ItemsSource = dataTable.DefaultView;

                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                }
                finally
                {
                    connection.Close();
                }
            }
        }

        private void raice_error(object sender, RoutedEventArgs e)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
            string query = "INSERT INTO CrewMember (Name, Experience) VALUES ('John Doe', 'Invalid')";

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();

                SqlTransaction transaction = connection.BeginTransaction();

                try
                {
                    SqlCommand command = new SqlCommand(query, connection, transaction);
                    SqlDataAdapter adapter = new SqlDataAdapter(command);
                    DataTable dataTable = new DataTable();

                    adapter.Fill(dataTable);

                    CrewMembersGrid.ItemsSource = dataTable.DefaultView;

                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    MessageBox.Show("");
                }
                finally
                {
                    connection.Close();
                }
            }
        }

        private int currentIndex = 0;
        private void prew_crew(object sender, RoutedEventArgs e)
        {
            if (currentIndex > 0)
            {
                currentIndex--;
            }
            else
            {
                currentIndex = CrewMembersGrid.Items.Count - 2;
            }

            ShowCurrentItem();

            if (CrewMembersGrid.SelectedItem != null)
            {
                DataRowView selectedRow = (DataRowView)CrewMembersGrid.SelectedItem;
                if (selectedRow["ID"] != null && selectedRow["Full_Name"] != null && selectedRow["Position"] != null &&
                    selectedRow["Age"] != null && selectedRow["Experience"] != null && selectedRow["Photo"] != null && selectedRow["Airplane_ID"] != null)
                {
                    var selectedData = new
                    {
                        ID = selectedRow["ID"],
                        Full_Name = selectedRow["Full_Name"],
                        Position = selectedRow["Position"],
                        Age = selectedRow["Age"],
                        Experience = selectedRow["Experience"],
                        Photo = selectedRow["Photo"],
                        Airplane_ID = selectedRow["Airplane_ID"]
                    };
                    FillFields(selectedData.ID.ToString(), selectedData.Full_Name.ToString(), Convert.ToInt32(selectedData.Age), selectedData.Experience.ToString(), selectedData.Position.ToString(), selectedData.Photo.ToString(), selectedData.Airplane_ID.ToString());
                }
                else
                { }
            }
        }

        private void ShowCurrentItem()
        {
            if (currentIndex >= 0 && currentIndex < CrewMembersGrid.Items.Count)
            {
                CrewMembersGrid.SelectedIndex = currentIndex;
                CrewMembersGrid.ScrollIntoView(CrewMembersGrid.SelectedItem);
            }
        }

        private void next_crew(object sender, RoutedEventArgs e)
        {
            if (currentIndex >= CrewMembersGrid.Items.Count - 2)
            {
                currentIndex = 0;
            }
            else
            {
                currentIndex++;
            }
            ShowCurrentItem();

            if (CrewMembersGrid.SelectedItem != null)
            {
                DataRowView selectedRow = (DataRowView)CrewMembersGrid.SelectedItem;
                if (selectedRow["ID"] != null && selectedRow["Full_Name"] != null && selectedRow["Position"] != null &&
                    selectedRow["Age"] != null && selectedRow["Experience"] != null && selectedRow["Photo"] != null && selectedRow["Airplane_ID"] != null)
                {
                    var selectedData = new
                    {
                        ID = selectedRow["ID"],
                        Full_Name = selectedRow["Full_Name"],
                        Position = selectedRow["Position"],
                        Age = selectedRow["Age"],
                        Experience = selectedRow["Experience"],
                        Photo = selectedRow["Photo"],
                        Airplane_ID = selectedRow["Airplane_ID"]
                    };
                    FillFields(selectedData.ID.ToString(), selectedData.Full_Name.ToString(), Convert.ToInt32(selectedData.Age), selectedData.Experience.ToString(), selectedData.Position.ToString(),selectedData.Photo.ToString(), selectedData.Airplane_ID.ToString());
                }
                else
                { }
            }
        }

        public void FillFields(string id, string name, int age, string exp, string position,string photo, string airplaneId)
        {
            CrewId.Text = id;
            CrewName.Text = name;
            CrewAge.Text = age.ToString();
            CrewExp.Text = exp;
            PositionComboBox.Text = position;
            IdAirplain.Text = airplaneId;
            SelectedPhotoImage.Source = new BitmapImage(new Uri(photo));
        }






        private void prew_plane(object sender, RoutedEventArgs e)
        {
            if (currentIndex2 > 0)
            {
                currentIndex2--;
            }
            else
            {
                currentIndex2 = AirplaneGrid.Items.Count - 2;
            }

            ShowCurrentItem2();

            if (AirplaneGrid.SelectedItem != null)
            {
                DataRowView selectedRow = (DataRowView)AirplaneGrid.SelectedItem;
                if (selectedRow["ID"] != null && selectedRow["Type"] != null && selectedRow["Model"] != null && selectedRow["Passenger_Seats"] != null && selectedRow["Year_of_Manufacture"] != null && selectedRow["Cargo_Capacity"] != null && selectedRow["Last_Maintenance_Date"] != null)
                {
                    var selectedData = new
                    {
                        ID = selectedRow["ID"],
                        Type = selectedRow["Type"],
                        Model = selectedRow["Model"],
                        Passenger_Seats = selectedRow["Passenger_Seats"],
                        Year_of_Manufacture = selectedRow["Year_of_Manufacture"],
                        Cargo_Capacity = selectedRow["Cargo_Capacity"],
                        Last_Maintenance_Date = selectedRow["Last_Maintenance_Date"]
                    };
                    FillFields2(selectedData.ID.ToString(), selectedData.Type.ToString(), selectedData.Cargo_Capacity.ToString(),
                selectedData.Year_of_Manufacture.ToString(), selectedData.Passenger_Seats.ToString(),
                selectedData.Model.ToString(), (DateTime)selectedData.Last_Maintenance_Date);
                }
                else
                { }
            }
        }

        public void FillFields2(string id, string type, string cargoCapacity, string yearOfManufacture, string passengerSeats, string model, DateTime lastMaintenanceDate)
        {
            AirplaneIDTextBox.Text = id;

            foreach (ComboBoxItem item in AirplaneTypeComboBox.Items)
            {
                if (item.Content.ToString() == type)
                {
                    item.IsSelected = true;
                    break;
                }
            }

            CargoCapacityTextBox.Text = cargoCapacity;
            YearOfManufactureTextBox.Text = yearOfManufacture;
            PassengerSeatsTextBox.Text = passengerSeats;
            ModelTextBox.Text = model;
            LastMaintenanceDatePicker.SelectedDate = lastMaintenanceDate;
        }

        private int currentIndex2 = 0;
        private void ShowCurrentItem2()
        {
            if (currentIndex2 >= 0 && currentIndex2 < AirplaneGrid.Items.Count)
            {
                AirplaneGrid.SelectedIndex = currentIndex2;
                AirplaneGrid.ScrollIntoView(AirplaneGrid.SelectedItem);
            }
        }

        private void next_plane(object sender, RoutedEventArgs e)
        {
            if (currentIndex2 >= AirplaneGrid.Items.Count - 2)
            {
                currentIndex2 = 0;
            }
            else
            {
                currentIndex2++;
            }
            ShowCurrentItem2();


            if (AirplaneGrid.SelectedItem != null)
            {
                DataRowView selectedRow = (DataRowView)AirplaneGrid.SelectedItem;
                if (selectedRow["ID"] != null && selectedRow["Type"] != null && selectedRow["Model"] != null && selectedRow["Passenger_Seats"] != null && selectedRow["Year_of_Manufacture"] != null && selectedRow["Cargo_Capacity"] != null && selectedRow["Last_Maintenance_Date"] != null)
                {
                    var selectedData = new
                    {
                        ID = selectedRow["ID"],
                        Type = selectedRow["Type"],
                        Model = selectedRow["Model"],
                        Passenger_Seats = selectedRow["Passenger_Seats"],
                        Year_of_Manufacture = selectedRow["Year_of_Manufacture"],
                        Cargo_Capacity = selectedRow["Cargo_Capacity"],
                        Last_Maintenance_Date = selectedRow["Last_Maintenance_Date"]
                    };
                    FillFields2(selectedData.ID.ToString(), selectedData.Type.ToString(), selectedData.Cargo_Capacity.ToString(),
                selectedData.Year_of_Manufacture.ToString(), selectedData.Passenger_Seats.ToString(),
                selectedData.Model.ToString(), (DateTime)selectedData.Last_Maintenance_Date);
                }
                else
                { }
            }
        }
    }
}
