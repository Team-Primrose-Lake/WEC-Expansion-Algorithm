# Import Libraries
import streamlit as st

import numpy as np


# Set the page layout and title
st.set_page_config(page_title="Multi-Page Streamlit App", layout="wide")

# Set the title of the web app
st.title("Website Sample!")

# Add a header to introduce the app
st.header("Welcome to My First Streamlit App")

# Add a brief description
st.write("This app demonstrates basic Streamlit components with examples and explanations.")

# Divider for visual separation
st.divider()

# Create an input section using Streamlit components
st.subheader("Interactive Input Section")

# Text input field for the user to enter their name
name = st.text_input("Enter your name:")

# Number input field for age
age = st.number_input("Enter your age:", min_value=0, max_value=120, step=1)

# Display entered information dynamically
if name and age:
    st.success(f"Hello, {name}! You are {age} years old.")

# Divider for the next section
st.divider()


# Create a sidebar for additional controls
st.sidebar.header("Sidebar Controls")

st.sidebar.title("Navigation")


# Slider for selecting a value
slider_value = st.sidebar.slider("Select a value:", 0, 100, 50)

# Checkbox to toggle information
show_more_info = st.sidebar.checkbox("Show more information")

# Display more information if checkbox is checked
if show_more_info:
    st.sidebar.write("This is additional information displayed based on your choice.")

# Divider for visual separation
st.divider()

# Add an image section
st.subheader("Image Display")

# Display an image from a URL
st.image("https://static.streamlit.io/examples/owl.jpg", caption="An owl", width=300)

# Divider for visual separation
st.divider()

# Create a graph using Streamlit and NumPy
st.subheader("Data Visualization Example")

# Import NumPy for data generation
import numpy as np

# Generate random data for the graph
x = np.linspace(0, 10, 100)
y = np.sin(x)

# Create a line chart
st.line_chart({"x": x, "y": y}, use_container_width=True)

# Divider for visual separation
st.divider()

# Add a download button for sharing data
st.subheader("Download Example")

# Example data to download
example_data = """
Name,Age,Score
Alice,24,89
Bob,30,95
Charlie,22,78
"""

# Button to download the example data as a CSV
st.download_button(
    label="Download Example Data",
    data=example_data,
    file_name="example_data.csv",
    mime="text/csv"
)

# Add a footer message
st.write("Thank you for exploring this app!")

# End of the Streamlit app

#Description: Run the app via terminal block
#Author: Mohammad Vohra
#Date: Jan 25, 2025
#URL: https://www.linkedin.com/pulse/transform-your-applications-how-convert-streamlit-app-mohammad-vohra-1qfsf/
import streamlit.web.cli as stcli
import os, sys

def resolve_path(path):
    return os.path.abspath(os.path.join(os.getcwd(), path))


if __name__ == "__main__":
    sys.argv = [
        "streamlit",
        "run",
        resolve_path("app.py"),
        "--global.developmentMode=false",
    ]
    sys.exit(stcli.main())