import React, { PureComponent } from "react";
import PropTypes from "prop-types";
import { SafeAreaView, View, StyleSheet, TextInput } from "react-native";
import { Formik } from "formik";

import {
  StyleProvider,
  Container,
  Button,
  Text,
   } from "native-base";

import getTheme from "../../native-base-theme/components";
import commonColor from "../../native-base-theme/variables/commonColor";

import { TextSignUpMidTitle } from "../components/TextSignUpMidTitle";
import { SwitchCustom } from "../components/SwitchCustom";

const styles = StyleSheet.create({
  input: {
    borderColor: "#ededed",
    borderWidth: 1,
    height: 58,
    borderRadius: 4,
    paddingLeft: 14,
    color: "#6582ff",
    marginVertical: 5,
    fontSize: 18,
  },
});

class SignUpCreateAccountClinicianScreen extends PureComponent {
  state = {};

  onPressClinicianSetup = () => {
    const { navigateSignUpClinicianSetup } = this.props;
    navigateSignUpClinicianSetup();
  };

  render() {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: "#ffffff" }}>
        <StyleProvider style={getTheme(commonColor)}>
          <Container>
            <View style={{ flex: 1, justifyContent: "flex-end", margin: 16 }}>
              <TextSignUpMidTitle title="See all your patients and all their device data in one place." />

              <Formik
                initialValues={{ name: "" }}
                onSubmit={this.onPressContinue}
              >
                {formikProps => (
                  <React.Fragment>
                    <TextInput
                      style={styles.input}
                      onChangeText={formikProps.handleChange("name")}
                      placeholder="Email"
                      placeholderTextColor="#838383"
                    />
                    <TextInput
                      style={styles.input}
                      onChangeText={formikProps.handleChange("name")}
                      placeholder="Password"
                      placeholderTextColor="#838383"
                      secureTextEntry
                    />
                    <TextInput
                      style={styles.input}
                      onChangeText={formikProps.handleChange("name")}
                      placeholder="Confirm Password"
                      placeholderTextColor="#838383"
                      secureTextEntry
                    />
                    <View style={{ paddingTop: 30 }}>
                      <SwitchCustom
                        switchText="I accept the terms of the Tidepool Applications Terms of Use and Privacy Policy"
                        style={{ paddingTop: 10 }}
                      />
                    </View>

                    <View style={{ flex: 1, justifyContent: "flex-end" }}>
                      <Button
                        block
                        onPress={this.onPressClinicianSetup}
                      >
                        <Text>Continue</Text>
                      </Button>
                    </View>
                  </React.Fragment>
                )}
              </Formik>
            </View>
          </Container>
        </StyleProvider>
      </SafeAreaView>
    );
  }
}

SignUpCreateAccountClinicianScreen.propTypes = {
  navigateSignUpClinicianSetup: PropTypes.func.isRequired,
};

export default SignUpCreateAccountClinicianScreen;
