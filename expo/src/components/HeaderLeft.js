import React from "react";
import PropTypes from "prop-types";
import { Image, TouchableOpacity } from "react-native";

class HeaderLeft extends React.Component {
  onPressMenu = () => {
    this.props.navigation.navigate("DrawerOpen");
  };

  render() {
    return (
      <TouchableOpacity onPress={this.onPressMenu}>
        <Image
          style={{ marginLeft: 16 }}
          tintColor="white"
          source={require("../../assets/images/menu-button.png")}
        />
      </TouchableOpacity>
    );
  }
}

HeaderLeft.propTypes = {
  navigation: PropTypes.shape({
    navigate: PropTypes.func.isRequired,
    dispatch: PropTypes.func.isRequired,
    goBack: PropTypes.func.isRequired,
  }).isRequired,
};

export default HeaderLeft;