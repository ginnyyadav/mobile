import React, { PureComponent } from "react";
import { Font } from "expo";

function withExpoFontPreload(WrappedComponent, fonts) {
  return class extends PureComponent {
    constructor(props) {
      super(props);
      this.state = {
        isLoaded: false,
      };
    }

    async componentDidMount() {
      if (process.env.NODE_ENV !== "test") {
        await Font.loadAsync(fonts);
      }

      this.setState({
        isLoaded: true,
      });
    }

    render() {
      let result = null;
      if (this.state.isLoaded) {
        result = <WrappedComponent {...this.props} />;
      }
      return result;
    }
  };
}

export default withExpoFontPreload;