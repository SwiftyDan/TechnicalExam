//
//  UIControlerHelpers.swift
//  TechnicalExam
//
//  Created by Dan Albert Luab on 2/19/25.
//

import Combine
import UIKit

extension UIControl {
    struct EventPublisher: Publisher {
        typealias Output = UIControl
        typealias Failure = Never

        fileprivate var control: UIControl
        fileprivate var events: UIControl.Event

        func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
            let subscription = EventSubscription(subscriber: subscriber, control: control, events: events)
            subscriber.receive(subscription: subscription)
        }
    }

    func publisher(for events: UIControl.Event) -> EventPublisher {
        EventPublisher(control: self, events: events)
    }
}

private extension UIControl {
    class EventSubscription<Target: Subscriber>: Subscription where Target.Input == UIControl {
        private var subscriber: Target?
        private let control: UIControl

        init(subscriber: Target, control: UIControl, events: UIControl.Event) {
            self.subscriber = subscriber
            self.control = control
            control.addTarget(self, action: #selector(eventHandler), for: events)
        }

        func request(_ demand: Subscribers.Demand) {
            // We do nothing here as we only want to send events when they occur.
            // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
        }

        func cancel() {
            subscriber = nil
        }

        @objc private func eventHandler() {
            _ = subscriber?.receive(control)
        }
    }
}
